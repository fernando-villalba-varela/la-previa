import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drinkaholic/core/services/language_service.dart';

class TiebreakerHeaderWidget extends StatelessWidget {
  final bool isMVP;
  final bool isQuestionTiebreaker;
  final int tiedScore;
  final Animation<double> colorAnimation;

  const TiebreakerHeaderWidget({
    super.key,
    required this.isMVP,
    required this.isQuestionTiebreaker,
    required this.tiedScore,
    required this.colorAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isQuestionTiebreaker)
          AnimatedBuilder(
            animation: colorAnimation,
            builder: (context, child) {
              final color = Color.lerp(
                Colors.white,
                const Color(0xFF00FF00),
                colorAnimation.value,
              )!;
              return Text(
                Provider.of<LanguageService>(context).translate('tiebreaker_question_title'),
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              );
            },
          )
        else
          Text(
            isMVP
                ? Provider.of<LanguageService>(context).translate('tiebreaker_mvp_title')
                : Provider.of<LanguageService>(context).translate('tiebreaker_ratita_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 12),
        if (isQuestionTiebreaker)
          Text(
            Provider.of<LanguageService>(context).translate('tiebreaker_question_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          )
        else
          (isMVP
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    children: [
                      TextSpan(
                        text:
                            '${Provider.of<LanguageService>(context).translate('tiebreaker_mvp_subtitle_1')} $tiedScore ${Provider.of<LanguageService>(context).translate('tiebreaker_mvp_subtitle_2')} ',
                      ),
                      TextSpan(
                        text: Provider.of<LanguageService>(context).translate('mvp_highlight'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0xFFFFFF99),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              color: Color(0xFFFFFF99),
                              blurRadius: 8,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const TextSpan(text: ')'),
                    ],
                  ),
                )
              : RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    children: [
                      TextSpan(
                        text:
                            '${Provider.of<LanguageService>(context).translate('tiebreaker_ratita_subtitle_1')} $tiedScore ${Provider.of<LanguageService>(context).translate('tiebreaker_ratita_subtitle_2')}',
                      ),
                      TextSpan(
                        text: Provider.of<LanguageService>(context).translate('ratita_highlight'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0xFF8B4513),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              color: Color(0xFF8B4513),
                              blurRadius: 8,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const TextSpan(text: ')'),
                    ],
                  ),
                )),
      ],
    );
  }
}
