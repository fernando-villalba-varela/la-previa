import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiPainter extends CustomPainter {
  final double progress; // 0..1

  ConfettiPainter({required this.progress});

  final List<Color> colors = const [
    Color(0xFFFFD700),
    Color(0xFF00C9FF),
    Color(0xFF92FE9D),
    Color(0xFFFF6B6B),
    Color(0xFF7F5AF0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final count = 80;

    // Desvanecimiento gradual en los últimos 2 segundos (0.6 a 1.0)
    double globalOpacity = 1.0;
    if (progress > 0.6) {
      globalOpacity = 1.0 - ((progress - 0.6) / 0.4);
    }

    for (int i = 0; i < count; i++) {
      // Las partículas siempre caen hacia abajo
      final t = (i / count + progress * 0.7) % 1.0;
      final x = rnd.nextDouble() * size.width;
      final startY = -50.0 - rnd.nextDouble() * 200.0;
      final y = startY + t * (size.height + 300.0);
      final w = 4.0 + rnd.nextDouble() * 6.0;
      final h = 6.0 + rnd.nextDouble() * 10.0;
      final angle = rnd.nextDouble() * 3.1415;

      // Opacidad individual + opacidad global de desvanecimiento
      final individualOpacity = 1.0 - (t * 0.2);
      final finalOpacity = individualOpacity * globalOpacity;

      final paint = Paint()..color = colors[i % colors.length].withOpacity(finalOpacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2, -h / 2, w, h),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
