import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/league_list_viewmodel.dart';
import '../../../../core/services/language_service.dart'; // Import LanguageService

import '../../../../core/presentation/components/neon_background_layer.dart';
import '../../../../core/presentation/components/neon_header.dart';
import '../widgets/league_card.dart';
import '../widgets/league_empty_state.dart';
import '../widgets/fab_new_league.dart';
import '../../../../core/services/league_export_service.dart';
import '../../../../core/services/firebase_service.dart';
import 'league_qr_scanner_screen.dart';

class LeagueListScreen extends StatefulWidget {
  const LeagueListScreen({super.key});

  @override
  State<LeagueListScreen> createState() => _LeagueListScreenState();
}

class _LeagueListScreenState extends State<LeagueListScreen> with TickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    return Consumer<LeagueListViewModel>(
      builder: (_, vm, _) => Scaffold(
        backgroundColor: const Color(0xFF0B0B1A),
        body: NeonBackgroundLayer(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeonHeader(
                      title: Provider.of<LanguageService>(context).translate('play_league').toUpperCase(),
                      subtitle: Provider.of<LanguageService>(context).translate('leagues_title').toUpperCase(),
                      themeColor: const Color(0xFF00C9FF),
                      trailing: TextButton.icon(
                        onPressed: () => _showImportDialog(context),
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF00C9FF), size: 18),
                        label: Text(
                          Provider.of<LanguageService>(context, listen: false).translate('import_league_btn'),
                          style: const TextStyle(color: Color(0xFF00C9FF), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                    Expanded(
                      child: vm.leagues.isEmpty
                          ? const LeagueEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                              itemCount: vm.leagues.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 18),
                              itemBuilder: (_, i) => LeagueCard(league: vm.leagues[i]),
                            ),
                    ),
                  ],
                ),
                // FAB Izquierda - Reglas de liga
                Positioned(
                  bottom: 24,
                  left: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'rules',
                    foregroundColor: const Color(0xFF00C9FF),
                    backgroundColor: const Color(0xFF00C9FF).withOpacity(0.15),
                    elevation: 4,
                    onPressed: () => _showLeagueRulesModal(context),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(
                      Provider.of<LanguageService>(context, listen: false).translate('league_rules_btn'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                // FAB Derecha - Nueva liga
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: FabNewLeague(
                    onPressed: () => _showCreateLeagueDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLeagueRulesModal(BuildContext context) {
    final lang = Provider.of<LanguageService>(context, listen: false);
    const cyan = Color(0xFF00C9FF);

    final sections = [
      (Icons.people_alt_rounded, '👥', lang.translate('league_rules_s1_title'), lang.translate('league_rules_s1_body'), Colors.cyanAccent),
      (Icons.sports_esports_rounded, '🎮', lang.translate('league_rules_s2_title'), lang.translate('league_rules_s2_body'), Colors.purpleAccent),
      (Icons.local_bar_rounded, '🍹', lang.translate('league_rules_s3_title'), lang.translate('league_rules_s3_body'), Colors.blueAccent),
      (Icons.emoji_events_rounded, '🏆', lang.translate('league_rules_s4_title'), lang.translate('league_rules_s4_body'), Colors.amber),
      (Icons.sentiment_very_dissatisfied_rounded, '💩', lang.translate('league_rules_s5_title'), lang.translate('league_rules_s5_body'), Colors.pinkAccent),
      (Icons.casino_rounded, '🎰', lang.translate('league_rules_s6_title'), lang.translate('league_rules_s6_body'), Colors.orangeAccent),
      (Icons.group_rounded, '✨', lang.translate('league_rules_s7_title'), lang.translate('league_rules_s7_body'), Colors.greenAccent),
      (Icons.leaderboard_rounded, '📊', lang.translate('league_rules_s8_title'), lang.translate('league_rules_s8_body'), cyan),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF12122A), Color(0xFF0B0B1A)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: cyan.withOpacity(0.25), width: 1.2),
            boxShadow: [
              BoxShadow(color: cyan.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, -4)),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: cyan, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang.translate('league_rules_title'),
                        style: const TextStyle(
                          color: cyan,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          shadows: [Shadow(color: cyan, blurRadius: 10)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 20),
              // Secciones
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final (icon, emoji, title, body, color) = sections[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.25), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  body,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateLeagueDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16363F),
        title: Text(Provider.of<LanguageService>(context, listen: false).translate('create_new_league_title'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.cyanAccent,
          decoration: InputDecoration(
            labelText: Provider.of<LanguageService>(context, listen: false).translate('league_name_label'),
            labelStyle: const TextStyle(color: Colors.cyanAccent),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitCreateLeague(context, nameCtrl),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(Provider.of<LanguageService>(context, listen: false).translate('cancel'), style: const TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.cyan.shade700),
            onPressed: () => _submitCreateLeague(context, nameCtrl),
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('accept')),
          ),
        ],
      ),
    );
  }

  void _submitCreateLeague(BuildContext context, TextEditingController c) {
    final name = c.text.trim();
    if (name.isNotEmpty) {
      context.read<LeagueListViewModel>().createLeague(name);
    }
    Navigator.pop(context);
  }

  void _showImportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0B1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final lang = Provider.of<LanguageService>(context, listen: false);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                Text(
                  lang.translate('share_import_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  lang.translate('share_import_subtitle'),
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2BE2).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tag_rounded, color: Color(0xFF8A2BE2)),
                  ),
                  title: Text(lang.translate('share_code_6_title'), style: const TextStyle(color: Colors.white)),
                  subtitle: Text(lang.translate('share_code_6_subtitle'), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    _showSixDigitImport(context);
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C9FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF00C9FF)),
                  ),
                  title: Text(lang.translate('share_scan_qr_title'), style: const TextStyle(color: Colors.white)),
                  subtitle: Text(lang.translate('share_scan_qr_subtitle'), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    _scanQrCode(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSixDigitImport(BuildContext context) {
    final codeCtrl = TextEditingController();
    final lang = Provider.of<LanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0B0B1A),
        title: Text(lang.translate('share_code_6_title'), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang.translate('share_code_6_hint'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 2),
                ),
                hintText: 'ABC12X',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 22, letterSpacing: 4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(lang.translate('cancel_btn'), style: const TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2)),
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              if (code.length != 6) return;
              Navigator.pop(dialogContext);
              _importFromFirebase(code);
            },
            child: Text(lang.translate('import_btn')),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQrCode(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const LeagueQrScannerScreen(),
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      _importFromBase64(context, result);
    }
  }

  Future<void> _importFromFirebase(String code) async {
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    final leagueVM = context.read<LeagueListViewModel>();
    final lang = Provider.of<LanguageService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF00FFFF))),
    );
    try {
      final firebaseService = FirebaseService();
      final exportService = LeagueExportService();
      debugPrint('>>> Descargando liga con código: $code');
      final data = await firebaseService.downloadLeague(code);
      if (data == null) throw Exception(lang.translate('share_not_found'));
      debugPrint('>>> Liga descargada: ${data.league.name}');
      await exportService.importLeagueData(data);
      debugPrint('>>> Liga guardada en storage');
      navigator.pop();
      await leagueVM.reload();
      debugPrint('>>> ViewModel recargado');
      scaffold.showSnackBar(SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00FFAA), size: 20),
            const SizedBox(width: 10),
            Text(lang.translate('share_success'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF0D2D1A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 400, left: 32, right: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF00FFAA), width: 1),
        ),
        duration: const Duration(seconds: 3),
      ));
    } catch (e) {
      debugPrint('>>> ERROR importando: $e');
      navigator.pop();
      if (context.mounted) _showErrorDialog(context, e.toString());
    }
  }

  Future<void> _importFromBase64(BuildContext context, String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF00FFFF))),
    );
    try {
      final exportService = LeagueExportService();
      await exportService.importLeagueFromBase64(code);
      if (context.mounted) {
        Navigator.pop(context); // remove loading
        context.read<LeagueListViewModel>().reload();
        _showSuccessSnackbar(context, '¡Liga importada con éxito!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // remove loading
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A3A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final lang = Provider.of<LanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        title: Text(lang.translate('share_error_title'), style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
