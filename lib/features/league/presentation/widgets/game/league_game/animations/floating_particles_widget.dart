import 'package:flutter/material.dart';

class FloatingParticlesWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const FloatingParticlesWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  Widget _buildFloatingParticle(int index) {
    final random = (index * 1234) % 1000;
    final size = 4.0 + (random % 8);
    final left = (random * 0.7) % screenWidth;
    final top = (random * 0.8) % screenHeight;
    final opacity = 0.1 + (random % 40) / 100;

    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 3000 + (random % 2000)),
        tween: Tween<double>(begin: 0, end: 1),
        onEnd: () {},
        builder: (context, double value, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyan.withOpacity(opacity * (0.5 + 0.5 * value)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(20, (index) => _buildFloatingParticle(index)),
    );
  }
}
