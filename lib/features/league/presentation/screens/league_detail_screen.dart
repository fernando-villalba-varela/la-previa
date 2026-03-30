import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart'; // Import LanguageService
import '../viewmodels/league_detail_viewmodel.dart';
import '../widgets/league_app_bar_button.dart';
import 'package:drinkaholic/features/shared/presentation/widgets/animated_background.dart';
import '../widgets/detail/leaderboard_tab.dart';
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
  Widget _buildAnimatedBackground() {
    return const AnimatedBackground();
  }

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
          title: Row(
            children: [
              LeagueAppBarButton(
                onTap: () => Navigator.of(context).pop(),
                icon: Icons.arrow_back,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  league.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                      Shadow(
                        color: Colors.purple,
                        offset: Offset(-1, -1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // FUTURA IMPLEMENTACION: Exportar liga a JSON
              // LeagueAppBarButton(
              //   onTap: () => vm.showExportDialog(context),
              //   icon: Icons.upload_file,
              // ),
            ],
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
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
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
                      text:
                          Provider.of<LanguageService>(
                            context,
                          ).translate('custom_questions_tab'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
                ),
              ),
            ),
            _buildAnimatedBackground(),
            SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: TabBarView(
                  children: [
                    LeaderboardTab(),
                    ParticipantsTab(),
                    PlayTab(),
                    CustomQuestionsLeagueTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
