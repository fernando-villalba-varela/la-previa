import 'package:flutter/material.dart';
import 'confetti_painter.dart';

class ConfettiOverlay extends StatefulWidget {
  final AnimationController controller;

  const ConfettiOverlay({
    super.key,
    required this.controller,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final v = widget.controller.value;
        // Solo ocultar cuando esté completamente en 0.0 O cuando haya terminado completamente
        if (v == 0.0 || widget.controller.status == AnimationStatus.completed) {
          // Si está completado, esperar un momento antes de ocultar para que termine el desvanecimiento
          if (widget.controller.status == AnimationStatus.completed) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                widget.controller.reset();
              }
            });
          }
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          child: CustomPaint(
            painter: ConfettiPainter(progress: v),
          ),
        );
      },
    );
  }
}
