import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/participants_viewmodel.dart';
import '../../../../core/models/player.dart';
import '../../../../core/services/language_service.dart';
import 'package:drinkaholic/features/quick_game/presentation/screens/quick_game_screen.dart';
import 'package:drinkaholic/features/shared/presentation/widgets/animated_background.dart';
import '../../../../core/services/consent_and_ad_service.dart';
import '../widgets/participants/participants_export.dart';

class ParticipantsScreen extends StatelessWidget {
  final String title;
  const ParticipantsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParticipantsViewmodel(),
      child: const _ParticipantsScreenBody(),
    );
  }
}

class _ParticipantsScreenBody extends StatefulWidget {
  const _ParticipantsScreenBody();

  @override
  State<_ParticipantsScreenBody> createState() =>
      _ParticipantsScreenBodyState();
}

class _ParticipantsScreenBodyState extends State<_ParticipantsScreenBody>
    with TickerProviderStateMixin {
  List<Player> get _players =>
      Provider.of<ParticipantsViewmodel>(context).players;
  TextEditingController get _controller =>
      Provider.of<ParticipantsViewmodel>(context).controller;

  final _interstitial = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _interstitial.loadAd();
    });
  }

  @override
  void dispose() {
    _interstitial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ParticipantsViewmodel>(
      context,
      listen: false,
    );
    viewModel.context = context;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF0055), Color(0xFFFF5588)],
              ),
            ),
          ),
          const AnimatedBackground(),
          ...List.generate(8, (index) {
            final random = (index * 1234) % 1000;
            final size = 4.0 + (random % 8);
            final left = (random * 0.7) % MediaQuery.of(context).size.width;
            final top = (random * 0.8) % MediaQuery.of(context).size.height;
            final opacity = 0.1 + (random % 40) / 100;

            return Positioned(
              left: left,
              top: top,
              child: FloatingParticleWidget(
                size: size,
                opacity: opacity,
                duration: Duration(milliseconds: 3000 + (random % 2000)),
              ),
            );
          }),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFE0F7FA)],
                        ).createShader(bounds),
                        child: Text(
                          Provider.of<LanguageService>(
                            context,
                          ).translate('players_title'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: _players.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _players.length) {
                          return PlayerCardWidget(
                            index: index,
                            players: _players,
                          );
                        } else {
                          return AddPlayerCardWidget(controller: _controller);
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () async {
                          final viewModel = Provider.of<ParticipantsViewmodel>(
                            context,
                            listen: false,
                          );
                          if (viewModel.players.isNotEmpty) {
                            await _interstitial.showIfReady();
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QuickGameScreen(players: viewModel.players),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sports_esports,
                                color: Color(0xFFFF0055),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Provider.of<LanguageService>(
                                  context,
                                ).translate('start_playing_button'),
                                style: const TextStyle(
                                  color: Color(0xFFFF0055),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const SizedBox(
                width: double.infinity,
                child: BannerAdWidget(),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
