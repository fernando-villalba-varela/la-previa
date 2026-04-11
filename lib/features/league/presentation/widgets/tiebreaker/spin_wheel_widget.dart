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
      width: 290,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rueda
          SizedBox(
            width: 270,
            height: 270,
            child: AnimatedBuilder(
              animation: spinAnimation,
              builder: (context, child) {
                final angle = hasSpun ? finalBottleAngle : spinAnimation.value;
                return Transform.rotate(
                  angle: angle,
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
                );
              },
            ),
          ),

          // Indicador fijo (triángulo apuntando hacia abajo en el centro-top)
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(20, 16),
              painter: _TrianglePainter(),
            ),
          ),

          // Botón central
          GestureDetector(
            onTap: (isSpinning || hasSpun) ? null : onSpinTap,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF12121E),
                border: Border.all(
                  color: (isSpinning || hasSpun)
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFF00C9FF).withOpacity(0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSpinning || hasSpun)
                        ? Colors.black.withOpacity(0.3)
                        : const Color(0xFF00C9FF).withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: isSpinning
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : hasSpun
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white.withOpacity(0.9),
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GIRAR',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
