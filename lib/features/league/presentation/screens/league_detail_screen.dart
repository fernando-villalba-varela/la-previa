import 'package:flutter/material.dart';
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
}
