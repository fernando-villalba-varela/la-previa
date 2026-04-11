import 'package:flutter/material.dart';
import '../../../../core/models/game_state.dart';
import 'avatar_builders.dart';
import 'package:drinkaholic/features/shared/presentation/widgets/answer_info_button.dart';
import 'package:drinkaholic/features/quick_game/presentation/utils/pack_theme_extension.dart';

/// Construye el contenido de eventos globales
Widget buildEventContent(GameState gameState) {
  final isEndingEvent = gameState.isEndingEvent;

  return LayoutBuilder(
    builder: (context, constraints) {
      getResponsiveSize(
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

      getResponsiveSize(
        context,
        small: 20,
        medium: 30,
        large: 40,
      );

      getResponsiveSize(
        context,
        small: 15,
        medium: 25,
        large: 35,
      );

      final contentHeight = MediaQuery.of(context).size.height * 0.65;
      return SizedBox(
        height: contentHeight,
        child: Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Event type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEndingEvent
                    ? [Colors.purple.withOpacity(0.3), Colors.indigo.withOpacity(0.1)]
                    : [Colors.cyan.withOpacity(0.3), Colors.blue.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: isEndingEvent ? Colors.purple : Colors.cyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: (isEndingEvent ? Colors.purple : Colors.cyan).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEndingEvent ? Icons.check_circle : Icons.public,
                  color: isEndingEvent ? Colors.purple : Colors.cyan,
                  size: fontSize * 1.2,
                ),
                const SizedBox(width: 10),
                Text(
                  isEndingEvent ? 'EVENTO FINALIZADO' : 'NUEVO EVENTO GLOBAL',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isEndingEvent ? Colors.purple : Colors.cyan,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isEndingEvent ? Icons.check_circle : Icons.public,
                  color: isEndingEvent ? Colors.purple : Colors.cyan,
                  size: fontSize * 1.2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (!isEndingEvent)
            Text(
              'TODOS LOS JUGADORES',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
                shadows: const [
                  Shadow(color: Colors.black38, offset: Offset(3, 3), blurRadius: 6),
                  Shadow(color: Colors.cyan, offset: Offset(-1, -1), blurRadius: 3),
                ],
              ),
              textAlign: TextAlign.center,
            ),

          if (!isEndingEvent) const SizedBox(height: 20),

          // Event container with cosmic styling
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.85 + (0.15 * value),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(padding),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: gameState.packType == PackThemeType.classic
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isEndingEvent
                                    ? [Colors.purple.withOpacity(0.2), Colors.indigo.withOpacity(0.05)]
                                    : [Colors.cyan.withOpacity(0.2), Colors.blue.withOpacity(0.05)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: (isEndingEvent ? Colors.purple : Colors.cyan).withOpacity(0.5), width: 3),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10)),
                                BoxShadow(
                                  color: (isEndingEvent ? Colors.purple : Colors.cyan).withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: -2,
                                ),
                              ],
                            )
                          : gameState.cardDecoration.copyWith(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isEndingEvent ? Colors.purple.withOpacity(0.6) : gameState.themeBorderColor,
                                width: 3,
                              ),
                            ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              isEndingEvent ? gameState.currentEventEnd!.endDescription : gameState.currentChallenge!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                                shadows: [Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (gameState.themeIcon != null)
                      Positioned(
                        top: 15,
                        right: 30,
                        child: Icon(
                          gameState.themeIcon,
                          color: Colors.white.withOpacity(0.3),
                          size: 24,
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
      );
    },
  );
}
