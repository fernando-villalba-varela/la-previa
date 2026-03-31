import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/player.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import 'package:drinkaholic/core/presentation/components/drinkaholic_button.dart';
import '../viewmodels/tiebreaker_viewmodel.dart';
import '../widgets/tiebreaker/tiebreaker_export.dart';

export '../../models/tiebreaker_type.dart';

class TiebreakerScreen extends StatefulWidget {
  final List<Player> tiedPlayers;
  final int tiedScore;
  final TiebreakerType type;
  final Function(Player winner, Player? loser) onTiebreakerResolved;
  final bool isQuestionTiebreaker;
  final String? currentQuestion;
  final int drinksAmount;

  const TiebreakerScreen({
    super.key,
    required this.tiedPlayers,
    required this.tiedScore,
    required this.type,
    required this.onTiebreakerResolved,
    this.isQuestionTiebreaker = false,
    this.currentQuestion,
    this.drinksAmount = 1,
  });

  @override
  State<TiebreakerScreen> createState() => _TiebreakerScreenState();
}

class _TiebreakerScreenState extends State<TiebreakerScreen>
    with TickerProviderStateMixin {
  late TiebreakerViewModel _viewModel;
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _winnerScaleController;
  late Animation<double> _winnerScale;
  late AnimationController _colorChangeController;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _viewModel = TiebreakerViewModel(
      tiedPlayers: widget.tiedPlayers,
      tiedScore: widget.tiedScore,
      currentQuestion: widget.currentQuestion,
      drinksAmount: widget.drinksAmount,
    );

    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _winnerScaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _winnerScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _winnerScaleController, curve: Curves.elasticOut),
    );

    _colorChangeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _colorChangeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _winnerScaleController.dispose();
    _colorChangeController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _handleSpin() async {
    _viewModel.spinBottle();

    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: _viewModel.finalBottleAngle,
    ).animate(CurvedAnimation(parent: _spinController, curve: Curves.easeOut));

    await _spinController.forward();
    _winnerScaleController.forward(from: 0.0);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMVP = widget.type == TiebreakerType.mvp;
    final themeColor = isMVP ? const Color(0xFFFFD700) : const Color(0xFFFF7B7B);

    return Scaffold(
      body: NeonBackgroundLayer(
        child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  children: [
                    // Header
                    TiebreakerHeaderWidget(
                      isMVP: isMVP,
                      isQuestionTiebreaker: widget.isQuestionTiebreaker,
                      tiedScore: widget.tiedScore,
                      colorAnimation: _colorAnimation,
                    ),
                    const SizedBox(height: 32),

                    // Rueta con jugadores
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_viewModel.hasSpun &&
                              !_viewModel.isSpinning) ...[
                            Text(
                              Provider.of<LanguageService>(
                                context,
                              ).translate('spin_hint'),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                          ] else if (_viewModel.isSpinning) ...[
                            Text(
                              Provider.of<LanguageService>(
                                context,
                              ).translate('spinning_text'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                          ] else ...[
                            if (widget.isQuestionTiebreaker) ...[
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    const Color(0xFF00FF00),
                                    const Color(0xFF00CC00),
                                    const Color(0xFF00FF00),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ).createShader(bounds),
                                child: Text(
                                  Provider.of<LanguageService>(
                                    context,
                                  ).translate('elf_chooses'),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              Text(
                                isMVP
                                    ? Provider.of<LanguageService>(
                                        context,
                                      ).translate('mvp_winner_msg')
                                    : Provider.of<LanguageService>(
                                        context,
                                      ).translate('ratita_winner_msg'),
                                style: GoogleFonts.poppins(
                                  color: themeColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_viewModel.winner != null)
                              Center(
                                child: WinnerDisplayWidget(
                                  winner: _viewModel.winner!,
                                  isMVP: isMVP,
                                  isQuestionTiebreaker:
                                      widget.isQuestionTiebreaker,
                                  winnerScale: _winnerScale,
                                ),
                              ),
                            const SizedBox(height: 32),
                          ],

                          // Rueda
                          Center(
                            child: SpinWheelWidget(
                              players: widget.tiedPlayers,
                              winner: _viewModel.winner,
                              isMVP: isMVP,
                              hasSpun: _viewModel.hasSpun,
                              isSpinning: _viewModel.isSpinning,
                              finalBottleAngle: _viewModel.finalBottleAngle,
                              spinAnimation: _spinAnimation,
                              fixedColors: _viewModel.fixedColors,
                              playerImages: _viewModel.playerImages,
                              onSpinTap: _handleSpin,
                            ),
                          ),

                          if (widget.isQuestionTiebreaker &&
                              _viewModel.hasSpun &&
                              _viewModel.winner != null) ...[
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                '${Provider.of<LanguageService>(context).translate('question_tiebreaker_result_1')} ${_viewModel.extractQuestionPart()}${Provider.of<LanguageService>(context).translate('question_tiebreaker_result_2')} ${_viewModel.getDrinksFromQuestion()} ${Provider.of<LanguageService>(context).translate('drinks_count_suffix')}!',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Botón confirmar
                    Center(
                      child: Column(
                        children: [
                          if (_viewModel.hasSpun && _viewModel.winner != null)
                            DrinkaholicButton(
                              label: widget.isQuestionTiebreaker
                                  ? Provider.of<LanguageService>(
                                      context,
                                    ).translate('confirm')
                                  : Provider.of<LanguageService>(
                                      context,
                                    ).translate('confirm_result'),
                              icon: Icons.check_circle_outline,
                              onPressed: () {
                                final loser = widget.tiedPlayers.length > 1
                                    ? widget.tiedPlayers.firstWhere(
                                        (p) => p.id != _viewModel.winner!.id,
                                      )
                                    : null;
                                widget.onTiebreakerResolved(
                                  _viewModel.winner!,
                                  loser,
                                );
                              },
                              variant: DrinkaholicButtonVariant.accent,
                              fullWidth: false,
                              height: 52,
                            )
                          else if (_viewModel.isSpinning)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
