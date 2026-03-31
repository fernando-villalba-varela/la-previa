import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/participants_viewmodel.dart';
import '../../../../core/models/player.dart';
import '../../../../core/services/language_service.dart';
import 'package:drinkaholic/features/quick_game/presentation/screens/quick_game_screen.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../../../../core/presentation/components/neon_header.dart';
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

    // _buildSectionTitle is replaced by NeonHeader subtitle

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ParticipantsViewmodel>(
      context,
      listen: false,
    );
    viewModel.context = context;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      body: NeonBackgroundLayer(
        child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonHeader(
                  title: Provider.of<LanguageService>(context).translate('play_quick').toUpperCase(),
                  subtitle: Provider.of<LanguageService>(context).translate('players_title').toUpperCase(),
                  themeColor: const Color(0xFFFF0055),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Button Area
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF0055), Color(0xFFFF5588)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF0055).withOpacity(0.40),
                          blurRadius: 20,
                          spreadRadius: 1,
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
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¡A BEBER!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.sports_bar,
                                color: Colors.white,
                                size: 24,
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
      ),
    );
  }
}
