import 'package:flutter/material.dart';
import 'package:drinkaholic/core/models/player.dart';
import 'dart:ui' as ui;
import 'wheel_painter.dart';

class SpinWheelWidget extends StatelessWidget {
  final List<Player> players;
  final Player? winner;
  final bool isMVP;
  final bool hasSpun;
  final bool isSpinning;
  final double finalBottleAngle;
  final Animation<double> spinAnimation;
  final List<Color> fixedColors;
  final Map<String, ui.Image?> playerImages;
  final VoidCallback onSpinTap;

  const SpinWheelWidget({
    super.key,
    required this.players,
    required this.winner,
    required this.isMVP,
    required this.hasSpun,
    required this.isSpinning,
    required this.finalBottleAngle,
    required this.spinAnimation,
    required this.fixedColors,
    required this.playerImages,
    required this.onSpinTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: WheelPainter(
                players: players,
                winner: winner,
                isMVP: isMVP,
                hasSpun: hasSpun,
                fixedColors: fixedColors,
                playerImages: playerImages,
              ),
            ),
          ),
          GestureDetector(
            onTap: (isSpinning || hasSpun) ? null : onSpinTap,
            child: AnimatedBuilder(
              animation: spinAnimation,
              builder: (context, child) {
                final angle = hasSpun ? finalBottleAngle : spinAnimation.value;
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown.withOpacity(0.8),
                      border: Border.all(color: Colors.brown, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.local_drink, color: Colors.white, size: 30),
                        Positioned(
                          top: 8,
                          child: Container(
                            width: 4,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
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
    );
  }
}
