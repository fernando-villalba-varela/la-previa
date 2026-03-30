import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:drinkaholic/core/models/player.dart';

class WheelPainter extends CustomPainter {
  final List<Player> players;
  final Player? winner;
  final bool isMVP;
  final bool hasSpun;
  final List<Color> fixedColors;
  final Map<String, ui.Image?> playerImages;

  WheelPainter({
    required this.players,
    required this.winner,
    required this.isMVP,
    required this.hasSpun,
    required this.fixedColors,
    required this.playerImages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final anglePerSection = (2 * pi) / players.length;

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final isWinner = hasSpun && winner?.id == player.id;

      final startAngle = (i * anglePerSection) - (pi / 2);
      final sweepAngle = anglePerSection;

      Color sectionColor = fixedColors[i % fixedColors.length];

      final paint = Paint()
        ..color = sectionColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final endX = center.dx + radius * cos(startAngle);
      final endY = center.dy + radius * sin(startAngle);

      canvas.drawLine(center, Offset(endX, endY), linePaint);

      final sectionAngle = startAngle + (sweepAngle / 2);
      final avatarRadius = radius * 0.65;

      final avatarX = center.dx + avatarRadius * cos(sectionAngle);
      final avatarY = center.dy + avatarRadius * sin(sectionAngle);

      final textX = avatarX;
      final textY = avatarY + 35;

      _drawPlayerAvatar(canvas, player, avatarX, avatarY, 20, isWinner);

      final textPainter = TextPainter(
        text: TextSpan(
          text: player.nombre,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
            shadows: [Shadow(color: Colors.black.withOpacity(0.9), offset: const Offset(1, 1), blurRadius: 3)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));
    }

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawPlayerAvatar(Canvas canvas, Player player, double x, double y, double radius, bool isWinner) {
    final avatarPaint = Paint()
      ..color = isWinner ? (isMVP ? const Color(0xFFFFD700) : const Color(0xFF8B4513)) : Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius, avatarPaint);

    final ui.Image? playerImage = playerImages[player.nombre];

    if (playerImage != null) {
      _drawPlayerImage(canvas, playerImage, x, y, radius);
    } else {
      final textPainter = TextPainter(
        text: TextSpan(
          text: player.nombre.isNotEmpty ? player.nombre[0].toUpperCase() : '?',
          style: TextStyle(
            color: isWinner ? Colors.white : Colors.black,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(x, y), radius, borderPaint);
  }

  void _drawPlayerImage(Canvas canvas, ui.Image image, double x, double y, double radius) {
    final Rect rect = Rect.fromCircle(center: Offset(x, y), radius: radius);
    final Rect srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    canvas.drawImageRect(image, srcRect, rect, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
