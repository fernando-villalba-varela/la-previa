import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../viewmodels/league_detail_viewmodel.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../widgets/detail/leaderboard_tab.dart';
import '../../../../core/presentation/components/neon_header.dart';
import '../widgets/detail/participants_tab.dart';
import '../widgets/detail/play_tab.dart';
import '../widgets/detail/custom_questions_league_tab.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/league_export_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/league_storage_service.dart';
import '../../../../core/services/database_service_v2.dart';
import '../../../../core/models/league_export_data.dart';

class LeagueDetailScreen extends StatefulWidget {
  const LeagueDetailScreen({super.key});

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeagueDetailViewModel>();
    final league = vm.league;
    return DefaultTabController(
      length: 4, // REDUCIDO: De 5 a 4
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          title: NeonHeader(
            title: league.name.toUpperCase(),
            themeColor: const Color(0xFF00C9FF),
            padding: EdgeInsets.zero,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () => _showExportMenu(context, league.id),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0x4DFFFFFF), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: Color(0xFF00FFFF), width: 3),
                  ),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      text: Provider.of<LanguageService>(
                        context,
                      ).translate('scoreboard_tab'),
                    ),
                    Tab(
                      text: Provider.of<LanguageService>(
                        context,
                      ).translate('players_tab'),
                    ),
                    Tab(
                      text: Provider.of<LanguageService>(
                        context,
                      ).translate('play_tab'),
                    ),
                    Tab(
                      text: Provider.of<LanguageService>(
                        context,
                      ).translate('custom_questions_tab'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: NeonBackgroundLayer(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10), // REDUCIDO: De 80 a 10
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const LeaderboardTab(),
                  ParticipantsTab(),
                  const PlayTab(),
                  const CustomQuestionsLeagueTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExportMenu(BuildContext context, String leagueId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0B1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'EXPORTAR LIGA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: Color(0xFF00FFFF)),
              title: const Text(
                'Mostrar Código QR',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Comparte en persona escaneando la pantalla',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () {
                Navigator.pop(context);
                _showQrDialog(context, leagueId);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.send_rounded, color: Color(0xFF8A2BE2)),
              title: const Text(
                'Compartir Enlace/Código',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Copia un código largo o usa un código de 6 dígitos',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSharingOptions(context, leagueId);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showQrDialog(BuildContext context, String leagueId) async {
    final exportService = LeagueExportService();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00FFFF)),
      ),
    );

    try {
      final base64String = await exportService.exportLeagueToBase64(leagueId);
      if (context.mounted) Navigator.pop(context); // remove loading

      // QR Data limit check (Version 40 Alphanumeric max is ~4296 chars)
      // Base64 strings are alphanumeric.
      final bool isTooBig = base64String.length > 2800; 

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0B0B1A),
            title: const Text(
              'ESCANEA PARA IMPORTAR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  if (isTooBig) ...[
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Esta liga es demasiado grande para un código QR.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por favor, usa la opción de "Código de 6 dígitos" para compartir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: base64String,
                        version: QrVersions.auto,
                        size: 250.0,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        gapless: false,
                        errorStateBuilder: (cxt, err) {
                          return const Center(
                            child: Text(
                              'Error al generar QR.\nUsa el código de 6 dígitos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CERRAR', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // remove loading
      _showError(context, 'Error al generar la exportación: $e');
    }
  }

  Future<void> _showSharingOptions(
    BuildContext context,
    String leagueId,
  ) async {
    final lang = Provider.of<LanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0B1A),
        title: Text(
          lang.translate('share_league_title'),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(lang.translate('share_generate_code')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () async {
                Navigator.pop(context);
                _generateFirebaseCode(context, leagueId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateFirebaseCode(
    BuildContext context,
    String leagueId,
  ) async {
    final firebaseService = FirebaseService();
    final navigator = Navigator.of(context);
    final lang = Provider.of<LanguageService>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Get entire data
      // Use services directly
      final storageService = LeagueStorageService();
      final dbService = DatabaseService();

      final allLeaguesInternal = await storageService.loadLeagues();
      final league = allLeaguesInternal.firstWhere((l) => l.id == leagueId);
      final questions = await dbService.getPersonalizedQuestions(leagueId);

      final exportData = LeagueExportData(
        league: league,
        customQuestions: questions,
      );

      // 2. Upload to Firebase
      final code = await firebaseService.uploadLeague(exportData);

      navigator.pop(); // remove loading

      showDialog(
        context: navigator.context,
        builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0B0B1A),
            title: Text(
              lang.translate('share_code_generated_title'),
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang.translate('share_code_generated_subtitle'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FFFF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            color: Color(0xFF00FFFF),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.copy, color: Color(0xFF00FFFF), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang.translate('share_code_valid'),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Share.share(
                    '¡Únete a mi liga de La Previa! Código de acceso: $code',
                  );
                },
                child: Text(lang.translate('share_btn')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  lang.translate('close_btn'),
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        );
    } catch (e) {
      navigator.pop(); // remove loading
      if (context.mounted) {
        _showError(
          context,
          '${lang.translate('share_firebase_error')}\n\n$e',
        );
      }
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        title: const Text('Upps...', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
