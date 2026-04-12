import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quick_game_viewmodel.dart';
import '../widgets/quick_game_widgets.dart';
import '../widgets/modals_and_dialogs.dart';
import '../widgets/player_manager_modal.dart';
import '../utils/responsive_utils.dart' as responsive;
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../../../../core/models/player.dart';
import '../../../../core/models/constant_challenge.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/pack_service.dart';
import '../../../../features/home/presentation/screens/premium_offer_screen.dart';
import '../../../../core/services/analytics_service.dart';

class QuickGameScreen extends StatelessWidget {
  final List<Player> players;

  const QuickGameScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuickGameViewModel(
        context: context,
        initialPlayers: players,
      ),
      child: const _QuickGameScreenContent(),
    );
  }
}

class _QuickGameScreenContent extends StatefulWidget {
  const _QuickGameScreenContent();

  @override
  State<_QuickGameScreenContent> createState() =>
      _QuickGameScreenContentState();
}

class _QuickGameScreenContentState extends State<_QuickGameScreenContent>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _tapAnimationController;
  late AnimationController _rippleAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<double> _glowAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _rippleAnimation;

  final List<Offset> _ripplePositions = [];
  final List<double> _rippleOpacities = [];
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();

    // Forzar orientación horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapAnimationController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _glowAnimationController.repeat(reverse: true);
    _pulseAnimationController.repeat(reverse: true);

    // Inicializar primer desafío
    final packService = context.read<PackService>();
    final packs = packService.activePackIds.join(',');
    final isPremium = packService.isPremium;
    final quickGameVM = context.read<QuickGameViewModel>();
    Future.microtask(() {
      quickGameVM.initializeFirstChallenge();
      AnalyticsService().logGameStarted(mode: 'quick', packs: packs, isPremium: isPremium);
    });
  }

  @override
  void dispose() {
    // Restaurar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _cardAnimationController.dispose();
    _glowAnimationController.dispose();
    _tapAnimationController.dispose();
    _rippleAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _addRippleEffect(Offset position) {
    if (_rippleAnimationController.isAnimating) return;

    setState(() {
      _ripplePositions.clear();
      _rippleOpacities.clear();
      _ripplePositions.add(position);
      _rippleOpacities.add(1.0);
    });

    _rippleAnimationController.reset();
    _rippleAnimationController.forward().then((_) {
      setState(() {
        _ripplePositions.clear();
        _rippleOpacities.clear();
      });
    });
  }

  Future<void> _handleNextChallenge() async {
    final viewModel = context.read<QuickGameViewModel>();

    // Si hay temporizador y aún no ha arrancado, el primer tap lo inicia
    if (viewModel.createGameState().timerSeconds != null && !_timerStarted) {
      setState(() => _timerStarted = true);
      return;
    }

    _tapAnimationController.forward().then((_) {
      _tapAnimationController.reverse();
    });
    
    // Verificar checkpoint de endless mode
    if (await viewModel.checkEndlessModeCheckpoint()) {
      if (!mounted) return;
      final shouldContinue = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => EndlessModeCheckpointDialog(
          onContinue: () => Navigator.pop(context, true),
          onEnd: () => Navigator.pop(context, false),
        ),
      );

      if (shouldContinue == true) {
        viewModel.activateEndlessMode();
      } else {
        AnalyticsService().logGameCompleted(mode: 'quick', roundsPlayed: viewModel.currentRound);
        if (mounted) Navigator.of(context).pop();
        return;
      }
    }

    setState(() => _timerStarted = false);
    final adShown = await viewModel.nextChallenge();
    
    if (adShown && mounted) {
      final isPremium = context.read<PackService>().isPremium;
      if (!isPremium) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PremiumOfferScreen(
              nextRoute: MaterialPageRoute(builder: (context) => const SizedBox.shrink()),
              isModal: true,
              source: 'quick_game',
            ),
          ),
        );
      }
    }
  }

  void _openActiveChallengesModal() {
    final viewModel = context.read<QuickGameViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ActiveChallengesModal(
        isEndlessMode: viewModel.isEndlessMode,
        endlessModifier: viewModel.getEndlessModifier(),
        activeConstantChallenges: viewModel.constantChallenges
            .where((c) => c.status == ConstantChallengeStatus.active)
            .toList(),
        activeEvents: viewModel.events
            .where((e) => e.status == EventStatus.active)
            .toList(),
        currentRound: viewModel.currentRound,
      ),
    );
  }

  void _openPlayerManager() {
    final viewModel = context.read<QuickGameViewModel>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerManagerModal(
        initialPlayers: viewModel.players,
        onPlayersUpdated: (newPlayers) {
          viewModel.updatePlayers(newPlayers);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuickGameViewModel>();

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = responsive.getResponsiveSize(
              context,
              small: 35,
              medium: 40,
              large: 50,
            );

            final padding = responsive.getResponsiveSize(
              context,
              small: 16.0,
              medium: 24.0,
              large: 32.0,
            );

            return NeonBackgroundLayer(
              child: Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _tapAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _tapAnimation.value,
                                  child: GestureDetector(
                                    onTapDown: (details) {
                                      final RenderBox renderBox =
                                          context.findRenderObject() as RenderBox;
                                      final localPosition = renderBox
                                          .globalToLocal(details.globalPosition);
                                      _addRippleEffect(localPosition);
                                    },
                                    onTap: _handleNextChallenge,
                                    behavior: HitTestBehavior.opaque,
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: SingleChildScrollView(
                                            physics: const ClampingScrollPhysics(),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  buildCenterContent(
                                                    viewModel.createGameState(),
                                                    timerStarted: _timerStarted,
                                                  ),
                                                  if (!viewModel.gameStarted)
                                                    AnimatedBuilder(
                                                      animation: _glowAnimation,
                                                      builder: (context, child) {
                                                        return Container(
                                                          margin: const EdgeInsets.only(top: 20),
                                                          padding: const EdgeInsets.all(7),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(25),
                                                            border: Border.all(
                                                              color: Colors.white.withOpacity(_glowAnimation.value * 0.8),
                                                              width: 2,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.white.withOpacity(_glowAnimation.value * 0.3),
                                                                blurRadius: 15,
                                                                spreadRadius: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(
                                                                Icons.touch_app,
                                                                color: Colors.white.withOpacity(_glowAnimation.value),
                                                                size: 25,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(
                                                                'TOCA LA PANTALLA',
                                                                style: TextStyle(
                                                                  color: Colors.white.withOpacity(_glowAnimation.value),
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold,
                                                                  letterSpacing: 1.2,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_ripplePositions.isNotEmpty)
                                          AnimatedBuilder(
                                            animation: _rippleAnimation,
                                            builder: (context, child) {
                                              return Stack(
                                                children: _ripplePositions.asMap().entries.map((entry) {
                                                  final index = entry.key;
                                                  final position = entry.value;
                                                  final opacity = _rippleOpacities.length > index ? _rippleOpacities[index] : 0.0;
                                                  final animationValue = _rippleAnimation.value;
                                                  final size = 150.0 * animationValue;

                                                  return Positioned(
                                                    left: position.dx - (size / 2),
                                                    top: position.dy - (size / 2),
                                                    child: Container(
                                                      width: size,
                                                      height: size,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white.withOpacity(opacity * (1 - animationValue) * 0.6),
                                                          width: 3,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: padding,
                    right: padding + iconSize + 24,
                    child: GestureDetector(
                      onTap: _openActiveChallengesModal,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.list_alt,
                          color: Colors.white,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: padding,
                    right: padding,
                    child: GestureDetector(
                      onTap: _openPlayerManager,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.group,
                          color: Colors.white,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: padding,
                    left: padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '${Provider.of<LanguageService>(context).translate('round')} ${viewModel.currentRound}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.getResponsiveSize(
                                context,
                                small: 14,
                                medium: 16,
                                large: 20,
                              ),
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
            );
          },
        ),
      ),
    );
  }
}
