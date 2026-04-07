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
}
