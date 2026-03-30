import 'package:flutter/material.dart';

class RippleEffectWidget extends StatelessWidget {
  final List<Offset> ripplePositions;
  final List<double> rippleOpacities;
  final Animation<double> rippleAnimation;

  const RippleEffectWidget({
    super.key,
    required this.ripplePositions,
    required this.rippleOpacities,
    required this.rippleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (ripplePositions.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: rippleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(ripplePositions.length, (index) {
            final position = ripplePositions[index];
            final maxRadius = 200.0;
            final currentRadius = rippleAnimation.value * maxRadius;
            final opacity = rippleOpacities[index] * (1 - rippleAnimation.value);

            return Positioned(
              left: position.dx - currentRadius,
              top: position.dy - currentRadius,
              child: Container(
                width: currentRadius * 2,
                height: currentRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.cyan.withOpacity(opacity * 0.5),
                    width: 2,
                  ),
                  color: Colors.cyan.withOpacity(opacity * 0.1),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
