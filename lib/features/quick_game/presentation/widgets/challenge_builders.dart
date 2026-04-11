import 'package:flutter/material.dart';
import '../../../../core/models/game_state.dart';
import 'avatar_builders.dart';
import '../utils/pack_theme_extension.dart';

/// Construye el contenido de retos constantes
Widget buildConstantChallengeContent(GameState gameState) {
  final isEndingChallenge = gameState.isEndingConstantChallenge;
  final isNewChallenge = gameState.isNewConstantChallenge;

  return LayoutBuilder(
    builder: (context, constraints) {
      final iconSize = getResponsiveSize(
        context,
        small: 35,
        medium: 40,
        large: 50,
      );

      final fontSize = getResponsiveSize(
        context,
        small: 18,
        medium: 22,
        large: 23,
      );

      final padding = getResponsiveSize(
        context,
        small: 18,
        medium: 28,
        large: 38,
      );

      final contentHeight = MediaQuery.of(context).size.height * 0.65;
      return SizedBox(
        height: contentHeight,
        child: Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Challenge type indicator with icon on the left
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isEndingChallenge ? Colors.green : Colors.orange).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  isEndingChallenge ? Icons.celebration : Icons.gavel,
                  size: iconSize * 1.0,
                  color: isEndingChallenge ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                  color: isEndingChallenge ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isEndingChallenge ? Colors.green : Colors.orange, width: 2),
                ),
                child: Text(
                  isEndingChallenge ? 'RETO FINALIZADO' : 'NUEVO RETO CONSTANTE',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isEndingChallenge ? Colors.green : Colors.orange,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Challenge container with special styling
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(padding),
                margin: EdgeInsets.symmetric(horizontal: padding),
                decoration: gameState.packType == PackThemeType.classic
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isEndingChallenge
                              ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                              : [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: (isEndingChallenge ? Colors.green : Colors.orange).withOpacity(0.4), width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                      )
                    : gameState.cardDecoration.copyWith(
                        border: Border.all(
                          color: isEndingChallenge ? Colors.green.withOpacity(0.6) : gameState.themeBorderColor,
                          width: 2,
                        ),
                      ),
                child: Column(
                  children: [
                    Text(
                      isEndingChallenge ? gameState.currentChallengeEnd!.endDescription : gameState.currentChallenge!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(1, 1), blurRadius: 2)],
                      ),
                    ),
                  ],
                ),
              ),
              if (gameState.themeIcon != null)
                Positioned(
                  top: 12,
                  right: padding + 12,
                  child: Icon(
                    gameState.themeIcon,
                    color: Colors.white.withOpacity(0.3),
                    size: 24,
                  ),
                ),
            ],
          ),
        ],
        ),
        ),
      );
    },
  );
}
