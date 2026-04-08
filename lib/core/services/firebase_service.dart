import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/league_export_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateShortCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Without I, O, 1, 0 to avoid confusion
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))
    ));
  }

  /// Sube la liga a Firestore y devuelve un código de 6 dígitos.
  Future<String> uploadLeague(LeagueExportData data) async {
    int attempts = 0;
    while (attempts < 5) {
      final code = _generateShortCode();
      final docRef = _firestore.collection('shared_leagues').doc(code);

      try {
        final existing = await docRef.get();
        if (existing.exists) {
          attempts++;
          continue; // Code collision, try a new one
        }

        final dynamic dataJson = data.toJson();
        
        await docRef.set({
          'data': jsonEncode(dataJson), // Store as string for flexibility
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(), // Optional for cleanup
        });
        
        return code;
      } catch (e) {
        throw Exception('Error de conexión al compartir liga. (Asegurate de que las reglas de Firebase estén correctas): $e');
      }
    }
    throw Exception('No se pudo generar un código único en Firebase.');
  }

  /// Descarga los datos de una liga a partir de un código de 6 dígitos.
  Future<LeagueExportData?> downloadLeague(String code) async {
    try {
      final codeUpper = code.trim().toUpperCase();
      final docSnapshot = await _firestore.collection('shared_leagues').doc(codeUpper).get();

      if (!docSnapshot.exists) {
        return null; // Return null if not found
      }

      final docData = docSnapshot.data();
      if (docData == null || !docData.containsKey('data')) {
        return null;
      }

      final jsonString = docData['data'] as String;
      final j = jsonDecode(jsonString) as Map<String, dynamic>;

      return LeagueExportData.fromJson(j);
    } catch (e) {
      if (kDebugMode) {
        print('Error validando codigo Firebase: $e');
      }
      throw Exception('Error al conectar con la base de datos de Códigos Cortos.');
    }
  }
}
