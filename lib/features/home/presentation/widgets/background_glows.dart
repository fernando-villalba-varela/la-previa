import 'package:flutter/material.dart';

class BackgroundGlows extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const BackgroundGlows({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow top-left
        Positioned(
          top: -screenHeight * 0.1,
          left: -screenWidth * 0.3,
          child: Container(
            width: screenWidth * 1.2,
            height: screenWidth * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8A2BE2).withOpacity(0.2), // Neon Violet
                  Colors.transparent,
                ],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        ),
        // Glow bottom-right
        Positioned(
          bottom: -screenHeight * 0.1,
          right: -screenWidth * 0.4,
          child: Container(
            width: screenWidth * 1.2,
            height: screenWidth * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF0055).withOpacity(0.15), // Crimson Fiesta
                  Colors.transparent,
                ],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
