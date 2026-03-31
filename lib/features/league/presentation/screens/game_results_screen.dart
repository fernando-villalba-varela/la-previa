import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/player.dart';
import '../../../../core/services/language_service.dart';
import '../viewmodels/game_results_viewmodel.dart';
import '../widgets/game/results/results_export.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import 'tiebreaker_screen.dart';

class GameResultsScreen extends StatefulWidget {
  final List<Player> players;
  final Map<int, int> playerDrinks;
  final int maxRounds;
  final VoidCallback onConfirm;
  final Map<int, String>? streakMessages;

  const GameResultsScreen({
    super.key,
    required this.players,
    required this.playerDrinks,
    required this.maxRounds,
    required this.onConfirm,
    this.streakMessages,
  });

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen>
    with TickerProviderStateMixin {
  late GameResultsViewModel _viewModel;
  late AnimationController _confettiController;
  late AnimationController _glowController;
  late AnimationController _orientationFadeController;
  late Animation<double> _orientationFade;
  bool _showOrientationOverlay = true;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _viewModel = GameResultsViewModel();

    // Controladores de animación
    _orientationFadeController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _orientationFade = CurvedAnimation(
      parent: _orientationFadeController,
      curve: Curves.easeInOut,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Manejo de orientación
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _orientationFadeController.forward();
      await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      );
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      await _orientationFadeController.reverse();
      if (mounted) {
        setState(() => _showOrientationOverlay = false);
      }

      // Validar desempates e iniciar confeti
      _checkForTiebreakersAndStartConfetti();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _confettiController.dispose();
    _orientationFadeController.dispose();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    super.dispose();
  }

  void _checkForTiebreakersAndStartConfetti() {
    if (_viewModel.shouldShowConfetti(widget.players, widget.playerDrinks)) {
      _startConfettiAnimation();
    } else {
      _checkForTiebreakers();
    }
  }

  void _checkForTiebreakers() {
    if (_viewModel.hasMVPTie(widget.players, widget.playerDrinks)) {
      _showMVPTiebreaker();
    } else if (_viewModel.hasRatitaTie(widget.players, widget.playerDrinks)) {
      _showRatitaTiebreaker();
    }
  }

  void _showMVPTiebreaker() {
    final tiedPlayers = _viewModel.getMVPTiedPlayers(
      widget.players,
      widget.playerDrinks,
    );
    final maxDrinks = _viewModel.getMaxDrinks(widget.playerDrinks);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TiebreakerScreen(
          tiedPlayers: tiedPlayers,
          tiedScore: maxDrinks,
          type: TiebreakerType.mvp,
          onTiebreakerResolved: (winner, loser) {
            _viewModel.setResolvedMVP(winner);
            Navigator.pop(context);

            // Verificar si hay empate Ratita después
            if (_viewModel.hasRatitaTie(widget.players, widget.playerDrinks)) {
              _showRatitaTiebreaker();
            } else {
              _startConfettiAnimation();
            }
          },
        ),
      ),
    );
  }

  void _showRatitaTiebreaker() {
    final tiedPlayers = _viewModel.getRatitaTiedPlayers(
      widget.players,
      widget.playerDrinks,
    );
    final minDrinks = _viewModel.getMinDrinks(widget.playerDrinks);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TiebreakerScreen(
          tiedPlayers: tiedPlayers,
          tiedScore: minDrinks,
          type: TiebreakerType.ratita,
          onTiebreakerResolved: (winner, loser) {
            _viewModel.setResolvedRatita(winner);
            Navigator.pop(context);
            _startConfettiAnimation();
          },
        ),
      ),
    );
  }

  void _startConfettiAnimation() {
    if (mounted) {
      _confettiController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleConfirm() {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600 || screenSize.height < 400;

    // Dimensiones adaptativas
    final headerPadding = isSmallScreen ? 16.0 : 24.0;
    final contentPadding = isSmallScreen ? 16.0 : 24.0;
    final iconSize = isSmallScreen ? 24.0 : 32.0;
    final titleFontSize = isSmallScreen ? 18.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 13.0 : 16.0;
    final buttonPadding = isSmallScreen ? 12.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 15.0 : 18.0;

    // Obtener jugadores MVP y Ratita del ViewModel
    final mvpPlayer = _viewModel.getMVPPlayer(widget.players, widget.playerDrinks);
    final ratitaPlayer =
        _viewModel.getRatitaPlayer(widget.players, widget.playerDrinks);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: NeonBackgroundLayer(
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    GameResultsHeader(
                      padding: headerPadding,
                      iconSize: iconSize,
                      titleFontSize: titleFontSize,
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(contentPadding),
                        child: Column(
                          children: [
                            Text(
                              '${Provider.of<LanguageService>(context).translate('rounds_completed_text')} ${widget.maxRounds} ${Provider.of<LanguageService>(context).translate('rounds')}',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: subtitleFontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            // MVP Card
                            if (mvpPlayer != null)
                              MVPCard(
                                player: mvpPlayer,
                                drinks: widget.playerDrinks[mvpPlayer.id] ?? 0,
                                glowAnimation: _glowController,
                                isSmallScreen: isSmallScreen,
                              ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            // Stats Section
                            if (ratitaPlayer != null)
                              GameStatsSection(
                                playerDrinks: widget.playerDrinks,
                                players: widget.players,
                                maxRounds: widget.maxRounds,
                                ratitaPlayer: ratitaPlayer,
                                glowAnimation: _glowController,
                                isSmallScreen: isSmallScreen,
                              ),
                            // Streak Messages
                            if (widget.streakMessages != null &&
                                widget.streakMessages!.isNotEmpty)
                              StreakMessagesSection(
                                players: widget.players,
                                streakMessages: widget.streakMessages!,
                                glowAnimation: _glowController,
                                isSmallScreen: isSmallScreen,
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Action Button
                    Padding(
                      padding: EdgeInsets.all(buttonPadding),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFE44D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isConfirming ? null : _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFF1A1500),
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 14 : 18,
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: buttonFontSize,
                              letterSpacing: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            Provider.of<LanguageService>(context)
                                .translate('save_and_return_button'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Confetti overlay
              ConfettiOverlay(controller: _confettiController),
              // Orientation overlay
              if (_showOrientationOverlay)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _orientationFade,
                    builder: (context, _) => Container(
                      color: Colors.black.withOpacity(_orientationFade.value),
                    ),
                  ),
                ),
            ],
          ),
        ),

      ),
    );
  }
}


