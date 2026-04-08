import 'dart:convert';
import 'package:archive/archive_io.dart';
import '../models/league_export_data.dart';
import 'league_storage_service.dart';
import 'database_service_v2.dart';

class LeagueExportService {
  final LeagueStorageService _storageService = LeagueStorageService();
  final DatabaseService _dbService = DatabaseService();

  /// Exports a league and its custom questions to a Base64 string
  Future<String> exportLeagueToBase64(String leagueId) async {
    final allLeagues = await _storageService.loadLeagues();
    final league = allLeagues.firstWhere((l) => l.id == leagueId);
    final questions = await _dbService.getPersonalizedQuestions(leagueId);

    final exportData = LeagueExportData(
      league: league,
      customQuestions: questions,
    );

    final jsonString = jsonEncode(exportData.toJson());
    final bytes = utf8.encode(jsonString);

    // ZLib compression (Deflate) is generally more efficient for raw data than GZip
    final compressed = ZLibEncoder().encode(bytes);
    
    return base64Encode(compressed);
  }

  /// Imports a league from a Base64 string
  Future<void> importLeagueFromBase64(String base64String) async {
    try {
      final bytes = base64Decode(base64String.trim());

      String jsonString;
      try {
        // Try to decompress with ZLib first
        final decompressed = ZLibDecoder().decodeBytes(bytes);
        jsonString = utf8.decode(decompressed);
      } catch (_) {
        try {
          // Try GZip fallback (for older exports if any)
          final decompressed = GZipDecoder().decodeBytes(bytes);
          jsonString = utf8.decode(decompressed);
        } catch (_) {
          // If it was not compressed, try literal
          jsonString = utf8.decode(bytes);
        }
      }

      final j = jsonDecode(jsonString);
      final exportData = LeagueExportData.fromJson(j);

      await importLeagueData(exportData);
    } catch (e) {
      throw Exception('Error al importar la liga: $e');
    }
  }

  /// Imports a league from a LeagueExportData object (used when downloading from Firebase)
  Future<void> importLeagueData(LeagueExportData exportData) async {
    try {
      // 1. Save League (SharedPrefs) - overwrites if same ID
      final allLeagues = await _storageService.loadLeagues();
      await _storageService.saveLeague(exportData.league, allLeagues);

      // 2. Save Questions (SQLite)
      await _dbService.savePersonalizedQuestions(exportData.customQuestions);
    } catch (e) {
      throw Exception('Error al importar la liga: $e');
    }
  }
}
