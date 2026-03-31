import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/league_list_viewmodel.dart';
import '../../../../core/services/language_service.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonHeader(
                  title: Provider.of<LanguageService>(context).translate('play_league').toUpperCase(),
                  subtitle: Provider.of<LanguageService>(context).translate('leagues_title').toUpperCase(),
                  themeColor: const Color(0xFFFFD700),
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
          ),
        ),
        floatingActionButton: FabNewLeague(
          onPressed: () => _showCreateLeagueDialog(context),
        ),
      ),
    );
  }

  void _showCreateLeagueDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Provider.of<LanguageService>(context, listen: false).translate('create_new_league_title'),
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: nameCtrl,
          style: GoogleFonts.inter(color: Colors.white),
          cursorColor: const Color(0xFFFFD700),
          decoration: InputDecoration(
            labelText: Provider.of<LanguageService>(context, listen: false).translate('league_name_label'),
            labelStyle: GoogleFonts.inter(color: const Color(0xFFFFD700)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFD700))),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitCreateLeague(context, nameCtrl),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Provider.of<LanguageService>(context, listen: false).translate('cancel'),
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF1A1500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _submitCreateLeague(context, nameCtrl),
            child: Text(
              Provider.of<LanguageService>(context, listen: false).translate('accept'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
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
