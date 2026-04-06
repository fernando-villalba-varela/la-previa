import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/models/game_state.dart';
import 'avatar_builders.dart';
import 'challenge_builders.dart';
import 'event_builders.dart';
import 'icon_helpers.dart';
import 'package:drinkaholic/features/shared/presentation/widgets/answer_info_button.dart';
import 'package:drinkaholic/features/quick_game/presentation/utils/pack_theme_extension.dart';

/// Construye el contenido central del juego
Widget buildCenterContent(GameState gameState) {
  if (gameState.currentChallenge != null) {
    // Verificar si es un evento
    if (gameState.isEvent) {
      return buildEventContent(gameState);
    }

    // Verificar si es un reto constante
    if (gameState.isConstantChallenge) {
      return buildConstantChallengeContent(gameState);
    }

    final isForAll = gameState.isChallengeForAll;

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
          large: 26,
        );

        final padding = getResponsiveSize(
          context,
          small: 18,
          medium: 28,
          large: 38,
        );

        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 500;

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current player indicator with glow (single or dual)
              AnimatedBuilder(
                animation: gameState.glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(gameState.glowAnimation.value * 0.6),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: isForAll
                        ? Icon(Icons.people, size: 50, color: Colors.white.withOpacity(gameState.glowAnimation.value))
                        : gameState.isDualChallenge
                            ? buildDualPlayerAvatars(gameState)
                            : _isGenericPlayerQuestion(gameState)
                                ? Icon(
                                    Icons.group,
                                    size: iconSize,
                                    color: Colors.white.withOpacity(gameState.glowAnimation.value),
                                  )
                                : _getPlayerIndexFromQuestion(gameState) != null
                                    ? buildSinglePlayerAvatarByIndex(gameState, _getPlayerIndexFromQuestion(gameState)!)
                                    : Icon(
                                        Icons.group,
                                        size: iconSize,
                                        color: Colors.white.withOpacity(gameState.glowAnimation.value),
                                      ),
                  );
                },
              ),

              SizedBox(height: isSmallScreen ? 5 : 10),

              // Enhanced Challenge text container
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(padding),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: gameState.packType == PackThemeType.classic
                              ? BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.10)],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 25,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, -5),
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 0),
                                      spreadRadius: -5,
                                    ),
                                  ],
                                )
                              : gameState.cardDecoration,
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, iconValue, child) {
                                  return Transform.rotate(
                                    angle: iconValue * 2 * pi,
                                    child: Icon(
                                      getDynamicIcon(gameState.currentChallenge!),
                                      size: iconSize + (sin(iconValue * 2 * pi) * 5),
                                      color: Colors.white.withOpacity(0.9 + (0.1 * iconValue)),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: isSmallScreen ? 10 : 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 400),
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.4,
                                        shadows: [
                                          Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4),
                                          Shadow(
                                            color: Colors.cyan.withOpacity(0.3),
                                            offset: const Offset(-1, -1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(gameState.currentChallenge!, textAlign: TextAlign.center),
                                    ),
                                  ),
                                  AnswerInfoButton(answer: gameState.currentAnswer),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (gameState.themeIcon != null)
                          Positioned(
                            top: 15,
                            right: 35,
                            child: Icon(
                              gameState.themeIcon,
                              color: Colors.white.withOpacity(0.4),
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  return const SizedBox.shrink();
}

/// Helper para detectar si es una pregunta genérica sin jugador específico
bool _isGenericPlayerQuestion(GameState gameState) {
  final challenge = gameState.currentChallenge;
  if (challenge == null || challenge.isEmpty) return true;

  for (final player in gameState.players) {
    if (challenge.contains('${player.nombre} bebe') || challenge.contains('${player.nombre} reparte')) {
      return false;
    }
  }

  return true;
}

/// Helper para obtener el índice del jugador si está mencionado en la pregunta
int? _getPlayerIndexFromQuestion(GameState gameState) {
  final challenge = gameState.currentChallenge;
  if (challenge == null || challenge.isEmpty) return null;

  for (int i = 0; i < gameState.players.length; i++) {
    final player = gameState.players[i];
    if (challenge.contains('${player.nombre} bebe') || challenge.contains('${player.nombre} reparte')) {
      return i;
    }
  }

  return null;
}
