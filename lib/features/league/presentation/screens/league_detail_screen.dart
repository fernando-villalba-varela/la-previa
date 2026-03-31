import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../viewmodels/league_detail_viewmodel.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../widgets/detail/leaderboard_tab.dart';
import '../../../../core/presentation/components/neon_header.dart';
import '../widgets/detail/participants_tab.dart';
import '../widgets/detail/play_tab.dart';
import '../widgets/detail/custom_questions_league_tab.dart';

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
      length: 4,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          title: NeonHeader(
            title: league.name.toUpperCase(),
            themeColor: const Color(0xFFFFD700),
            padding: EdgeInsets.zero,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A3E).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  labelColor: const Color(0xFFFFD700),
                  unselectedLabelColor: Colors.white60,
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(color: Color(0xFFFFD700), width: 3),
                    insets: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
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
              padding: const EdgeInsets.only(top: 80),
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
}
