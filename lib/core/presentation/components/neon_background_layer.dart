import 'package:flutter/material.dart';
import '../../../features/home/presentation/widgets/background_glows.dart';
import '../../../features/home/presentation/widgets/floating_particle.dart';

class NeonBackgroundLayer extends StatelessWidget {
  final Widget child;
  final bool showBottomRightGlow;
  final bool hideParticles;

  const NeonBackgroundLayer({
    super.key,
    required this.child,
    this.showBottomRightGlow = false,
    this.hideParticles = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(color: const Color(0xFF0B0B1A)),
        BackgroundGlows(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          showBottomRightGlow: showBottomRightGlow,
        ),
        if (!hideParticles)
          ...List.generate(
          35,
          (index) => FloatingParticle(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            index: index,
          ),
        ),
        child,
      ],
    );
  }
}
