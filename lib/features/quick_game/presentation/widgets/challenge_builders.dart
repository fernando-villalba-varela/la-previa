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

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    // Challenge text with star icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isEndingChallenge ? Icons.check_circle : Icons.star,
                          color: Colors.white.withOpacity(0.9),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            isEndingChallenge ? 'RETO FINALIZADO' : 'RETO CONSTANTE',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
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
      );
    },
  );
}

/// Construye la información del castigo
List<Widget> _buildPunishmentInfo(GameState gameState, BuildContext context) {
  final iconSize = getResponsiveSize(
    context,
    small: 25,
    medium: 30,
    large: 40,
  );

  final fontSize = getResponsiveSize(
    context,
    small: 18,
    medium: 22,
    large: 26,
  );

  final padding = getResponsiveSize(
    context,
    small: 18,
    medium: 28,
    large: 35,
  );

  final currentPlayerIndex = gameState.currentPlayerIndex;
  if (currentPlayerIndex < 0 || currentPlayerIndex >= gameState.players.length) {
    return [];
  }

  final currentPlayer = gameState.players[currentPlayerIndex];
  final activeChallenges = gameState.constantChallenges
      .where((c) => c.targetPlayer.id == currentPlayer.id && c.startRound == gameState.currentRound)
      .toList();
  final activeChallenge = activeChallenges.isEmpty ? null : activeChallenges.last;

  if (activeChallenge?.punishment == null) {
    return [];
  }

  return [
    const SizedBox(height: 7),
    Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.red, size: iconSize),
              const SizedBox(width: 8),
              Text(
                'CASTIGO',
                style: TextStyle(color: Colors.red, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            activeChallenge!.punishment,
            style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ];
}
