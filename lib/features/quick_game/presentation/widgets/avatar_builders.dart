import 'package:flutter/material.dart';
import '../../../../core/models/player.dart';
import '../../../../core/models/game_state.dart';

/// Helper function para construir la imagen del jugador
Widget buildPlayerImage(Player player, GameState gameState, BuildContext context) {
  final iconSize = getResponsiveSize(
    context,
    small: 30,
    medium: 40,
    large: 50,
  );

  return player.imagen != null
      ? Image.file(player.imagen!, fit: BoxFit.contain)
      : player.avatar != null
          ? Image.asset(player.avatar!, fit: BoxFit.contain)
          : Container(
              color: Colors.white.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Colors.white.withOpacity(gameState.glowAnimation.value),
                size: iconSize,
              ),
            );
}

/// Helper function para construir un avatar individual
Widget buildSinglePlayerAvatar(GameState gameState) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final avatarSize = getResponsiveSize(
        context,
        small: 60,
        medium: 80,
        large: 100,
      );

      final borderWidth = getResponsiveSize(context, small: 2, medium: 3, large: 4);

      final iconSize = getResponsiveSize(context, small: 30, medium: 40, large: 50);

      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(gameState.glowAnimation.value), width: borderWidth),
        ),
        child: ClipOval(
          child: gameState.currentPlayer!.imagen != null
              ? Image.file(gameState.currentPlayer!.imagen!, fit: BoxFit.contain)
              : gameState.currentPlayer!.avatar != null
                  ? Image.asset(gameState.currentPlayer!.avatar!, fit: BoxFit.contain)
                  : Container(
                      color: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(gameState.glowAnimation.value),
                        size: iconSize,
                      ),
                    ),
        ),
      );
    },
  );
}

/// Helper function para construir un avatar individual por índice
Widget buildSinglePlayerAvatarByIndex(GameState gameState, int playerIndex) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final avatarSize = getResponsiveSize(
        context,
        small: 60,
        medium: 80,
        large: 100,
      );

      final borderWidth = getResponsiveSize(context, small: 2, medium: 3, large: 4);

      final iconSize = getResponsiveSize(context, small: 30, medium: 40, large: 50);

      if (playerIndex < 0 || playerIndex >= gameState.players.length) {
        return Icon(Icons.group, size: avatarSize, color: Colors.white);
      }

      final player = gameState.players[playerIndex];

      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(gameState.glowAnimation.value), width: borderWidth),
        ),
        child: ClipOval(
          child: player.imagen != null
              ? Image.file(player.imagen!, fit: BoxFit.contain)
              : player.avatar != null
                  ? Image.asset(player.avatar!, fit: BoxFit.contain)
                  : Container(
                      color: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(gameState.glowAnimation.value),
                        size: iconSize,
                      ),
                    ),
        ),
      );
    },
  );
}

/// Helper function para construir avatares duales
Widget buildDualPlayerAvatars(GameState gameState) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final containerWidth = getResponsiveSize(context, small: 100, medium: 120, large: 140);

      final avatarSize = getResponsiveSize(context, small: 50, medium: 70, large: 90);

      final vsSize = getResponsiveSize(context, small: 25, medium: 30, large: 35);

      final vsFontSize = getResponsiveSize(context, small: 10, medium: 12, large: 14);

      return SizedBox(
        width: containerWidth,
        height: avatarSize,
        child: Stack(
          children: [
            // Primer avatar (izquierda)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(gameState.glowAnimation.value), width: 3),
                ),
                child: ClipOval(
                  child: buildPlayerImage(
                    gameState.currentPlayer!,
                    gameState,
                    context,
                  ),
                ),
              ),
            ),
            // Segundo avatar (derecha)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyan.withOpacity(gameState.glowAnimation.value * 0.8), width: 3),
                ),
                child: ClipOval(
                  child: buildPlayerImage(
                    gameState.dualPlayer!,
                    gameState,
                    context,
                  ),
                ),
              ),
            ),
            // Indicador VS
            Positioned(
              left: containerWidth / 2.75,
              top: avatarSize / 3,
              child: Container(
                width: vsSize,
                height: vsSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
                ),
                child: Center(
                  child: Text(
                    'VS',
                    style: TextStyle(fontSize: vsFontSize, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Helper function para obtener tamaños responsivos
double getResponsiveSize(BuildContext context, {required double small, required double medium, required double large}) {
  final width = MediaQuery.of(context).size.width;

  const breakpointSmall = 1000.0;
  const breakpointMedium = 1700.0;

  if (width <= breakpointSmall) {
    return small * 1.2;
  } else if (width <= breakpointMedium) {
    return medium * 1.5;
  } else {
    return large * 2;
  }
}
