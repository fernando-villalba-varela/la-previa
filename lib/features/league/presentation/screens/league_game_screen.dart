import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../../../../core/models/player.dart';
import '../../../../core/services/language_service.dart';

import '../../../../core/services/database_service_v2.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../../../../core/services/pack_service.dart';
import '../../../../core/services/analytics_service.dart';

import '../viewmodels/league_game_viewmodel.dart';
import '../widgets/game/game_card_widget.dart';
import '../widgets/game/player_selector_overlay.dart';
import '../widgets/game/letter_counter_overlay.dart';
import '../widgets/game/league_game/animations/ripple_effect_widget.dart';
import '../widgets/game/league_game/modals/challenges_modal_content.dart';
import '../screens/tiebreaker_screen.dart';

class LeagueGameScreen extends StatefulWidget {
  final List<Player> players;
  final int maxRounds;
  final String leagueId;
  final Function(Map<int, int>) onGameEnd;

  const LeagueGameScreen({
    super.key,
    required this.players,
    required this.maxRounds,
    required this.leagueId,
    required this.onGameEnd,
  });

  @override
  State<LeagueGameScreen> createState() => _LeagueGameScreenState();
}

class _LeagueGameScreenState extends State<LeagueGameScreen>
    with TickerProviderStateMixin {

  late LeagueGameViewModel _viewModel;

  // Animations
  late AnimationController _glowAnimationController;
  late AnimationController _tapAnimationController;
  late AnimationController _rippleAnimationController;
  late AnimationController _orientationFadeController;
  late Animation<double> _glowAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _orientationFade;

  bool _showOrientationOverlay = true;
  final List<Offset> _ripplePositions = [];
  final List<double> _rippleOpacities = [];

  DateTime? _lastTapTime;
  Timer? _toastTimer;
  bool _ratingHintShown = false;
  int _challengeCount = 0;

  @override
  void initState() {
    super.initState();

    _viewModel = LeagueGameViewModel(players: widget.players);

    _initAnimations();

    // Orientation transition
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Capture services before any await
      final db = context.read<DatabaseService>();
      final lang = context.read<LanguageService>();
      final packService = context.read<PackService>();

      await _orientationFadeController.forward();
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      await _orientationFadeController.reverse();
      if (mounted) setState(() => _showOrientationOverlay = false);

      await _viewModel.loadCustomQuestions(db, widget.leagueId);
      final activePackIds = packService.activePackIds.toList();
      await _viewModel.initializeFirstChallenge(lang, activePackIds);
      AnalyticsService().logGameStarted(
        mode: 'league',
        packs: activePackIds.join(','),
        isPremium: packService.isPremium,
      );

    });

  }

  void _initAnimations() {
    _orientationFadeController =
        AnimationController(duration: const Duration(milliseconds: 180), vsync: this);
    _orientationFade =
        CurvedAnimation(parent: _orientationFadeController, curve: Curves.easeInOut);

    _glowAnimationController =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowAnimationController, curve: Curves.easeInOut));
    _glowAnimationController.repeat(reverse: true);

    _tapAnimationController =
        AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _tapAnimationController, curve: Curves.easeInOut));

    _rippleAnimationController =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleAnimationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _glowAnimationController.dispose();
    _tapAnimationController.dispose();
    _rippleAnimationController.dispose();
    _orientationFadeController.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Game flow
  // ---------------------------------------------------------------------------

  void _handleTap() {
    _viewModel.applyDirectDrinksForCurrentPlayer();
    _nextChallenge();
  }

  void _nextChallenge() async {
    _tapAnimationController.forward().then((_) => _tapAnimationController.reverse());

    final lang = context.read<LanguageService>();
    final activePackIds = context.read<PackService>().activePackIds.toList();
    final gameEnded = await _viewModel.nextChallenge(lang, activePackIds, widget.maxRounds);
    if (gameEnded && mounted) { _endGame(); return; }

    _challengeCount++;
    if (_challengeCount == 1 && !_ratingHintShown && mounted) {
      _ratingHintShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lang.translate('rating_hint'),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _endGame() async {
    AnalyticsService().logGameCompleted(mode: 'league', roundsPlayed: _viewModel.currentRound);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    widget.onGameEnd(_viewModel.finalDrinks);
  }

  // ---------------------------------------------------------------------------
  // Interactions
  // ---------------------------------------------------------------------------

  void _addRippleEffect(Offset position) {
    if (_rippleAnimationController.isAnimating) return;
    setState(() {
      _ripplePositions
        ..clear()
        ..add(position);
      _rippleOpacities
        ..clear()
        ..add(1.0);
    });
    _rippleAnimationController.reset();
    _rippleAnimationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _ripplePositions.clear();
          _rippleOpacities.clear();
        });
      }
    });
  }

  void _handleDoubleTapForNobody() {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 1000) {
      _toastTimer?.cancel();
      _lastTapTime = null;
      _nextChallenge();
    } else {
      _lastTapTime = now;
      _toastTimer?.cancel();
      _toastTimer = Timer(const Duration(seconds: 1), () {
        if (mounted && _lastTapTime != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.info_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Si nadie cumple, pulsa rápido 2 veces',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.1,
                  left: 20,
                  right: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      });
    }
  }

  void _handleTiebreakerForMoreLikelyQuestion(List<int> selectedPlayerIds) {
    if (selectedPlayerIds.length <= 1) {
      _viewModel.applyMoreLikelyQuestionDrinks(selectedPlayerIds);
      Future.delayed(const Duration(milliseconds: 300), _nextChallenge);
      return;
    }

    final tiedPlayers =
        widget.players.where((p) => selectedPlayerIds.contains(p.id)).toList();
    final drinksAmount = _viewModel.extractDrinks();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TiebreakerScreen(
          tiedPlayers: tiedPlayers,
          tiedScore: 0,
          type: TiebreakerType.mvp,
          isQuestionTiebreaker: true,
          currentQuestion: _viewModel.currentChallenge,
          drinksAmount: drinksAmount,
          onTiebreakerResolved: (winnerPlayer, loserPlayer) {
            Navigator.of(context).pop();
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

            if (_viewModel.shouldCountDrinks()) {
              _viewModel.applyMoreLikelyQuestionDrinks([winnerPlayer.id]);
            } else {
              _viewModel.setShowingPlayerSelector(false);
            }

            Future.delayed(const Duration(milliseconds: 500), _nextChallenge);
          },
        ),
      ),
    );
  }

  void _openActiveChallengesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ChallengesModalContent(
          constantChallenges: _viewModel.constantChallenges,
          events: _viewModel.events,
          currentRound: _viewModel.currentRound,
          scrollController: scrollController,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: SafeArea(
        child: Scaffold(

          body: NeonBackgroundLayer(
            child: Stack(
              children: [
                SafeArea(child: _buildGameContent()),

              // Overlays driven by ViewModel state
              Consumer<LeagueGameViewModel>(
                builder: (ctx, vm, _) {
                  if (vm.showingPlayerSelector) {
                    return PlayerSelectorOverlay(
                      players: widget.players,
                      isMoreLikelyQuestion: vm.isMoreLikelyQuestion(),
                      onPlayersSelected: _handleTiebreakerForMoreLikelyQuestion,
                      onCancel: () => vm.setShowingPlayerSelector(false),
                    );
                  }
                  if (vm.showingLetterCounter) {
                    final selectedPlayers = widget.players
                        .where((p) =>
                            vm.selectedPlayerIdsForLetterCounter.contains(p.id))
                        .toList();
                    return LetterCounterOverlay(
                      selectedPlayers: selectedPlayers,
                      letter: vm.extractLetterToCount() ?? 'A',
                      drinksPerLetter: vm.extractDrinks(),
                      onConfirm: (drinksByPlayer) {
                        vm.applyLetterCounterDrinks(drinksByPlayer);
                        Future.delayed(
                            const Duration(milliseconds: 300), _nextChallenge);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Orientation fade overlay
              if (_showOrientationOverlay)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _orientationFade,
                    builder: (_, _) => Container(
                      color: Colors.black.withOpacity(_orientationFade.value),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<LeagueGameViewModel>(
          builder: (ctx, vm, _) {
            final gs = vm.createGameState(_glowAnimation);
            final isEnding = gs.isEndingConstantChallenge || gs.isEndingEvent;
            final hasActiveSelector = !isEnding &&
                vm.isConditionalQuestion() &&
                !vm.showingPlayerSelector &&
                !vm.showingLetterCounter;
            final isMoreLikelyAndNotSelected = !isEnding &&
                vm.isMoreLikelyQuestion() && !vm.showingPlayerSelector;

            final iconSize =
                _responsiveSize(context, small: 35, medium: 40, large: 50);
            final padding =
                _responsiveSize(context, small: 16, medium: 24, large: 32);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: hasActiveSelector
                  ? null
                  : (details) {
                      final box = context.findRenderObject() as RenderBox;
                      _addRippleEffect(
                          box.globalToLocal(details.globalPosition));
                    },
              onTap: hasActiveSelector
                  ? _handleDoubleTapForNobody
                  : (isMoreLikelyAndNotSelected
                      ? () => vm.setShowingPlayerSelector(true)
                      : _handleTap),
              child: AnimatedBuilder(
                animation: _tapAnimation,
                builder: (_, _) => Transform.scale(
                  scale: _tapAnimation.value,
                  child: Stack(
                    children: [
                      // Card
                      Padding(
                        padding: EdgeInsets.only(
                          top: _responsiveSize(context,
                              small: 70, medium: 110, large: 130),
                          bottom: _responsiveSize(context,
                              small: 10, medium: 30, large: 40),
                        ),
                        child: Stack(
                          children: [
                            GameCard(
                              gameState: vm.createGameState(_glowAnimation),
                              showPlayerSelector: hasActiveSelector,
                              onPlayersSelected: (selectedIds) {
                                if (vm.hasLetterMultiplier()) {
                                  final letter = vm.extractLetterToCount();
                                  if (letter != null) {
                                    if (selectedIds.isEmpty) {
                                      _nextChallenge();
                                      return;
                                    }
                                    vm.setLetterCounter(true, selectedIds);
                                    return;
                                  }
                                }
                                vm.applyMoreLikelyQuestionDrinks(selectedIds);
                                Future.delayed(const Duration(milliseconds: 300),
                                    _nextChallenge);
                              },
                            ),
                            RippleEffectWidget(
                              ripplePositions: _ripplePositions,
                              rippleOpacities: _rippleOpacities,
                              rippleAnimation: _rippleAnimation,
                            ),
                          ],
                        ),
                      ),

                      // Top-right: active challenges button
                      Positioned(
                        top: padding,
                        right: padding,
                        child: GestureDetector(
                          onTap: _openActiveChallengesModal,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: Icon(Icons.list_alt,
                                color: Colors.white, size: iconSize),
                          ),
                        ),
                      ),

                      // Top-left: back button + round counter
                      Positioned(
                        top: padding,
                        left: padding,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _confirmExit(context),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1),
                                ),
                                child: Icon(Icons.arrow_back,
                                    color: Colors.white, size: iconSize),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Text(
                                '${context.read<LanguageService>().translate('round_label')} ${vm.currentRound}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _responsiveSize(context,
                                      small: 14, medium: 16, large: 20),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmExit(BuildContext context) {
    final lang = context.read<LanguageService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.translate('exit_game_title')),
        content: Text(lang.translate('exit_game_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(lang.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(lang.translate('exit')),
          ),
        ],
      ),
    );
  }

  double _responsiveSize(BuildContext context,
      {required double small, required double medium, required double large}) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 1000) return small;
    if (width <= 1700) return medium * 1.5;
    return large * 2;
  }
}
