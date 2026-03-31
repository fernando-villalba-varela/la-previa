import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Animation<double> opacityAnimation;
  final Animation<double> iconScaleAnimation;
  final Gradient gradient;
  final String buttonText;
  final IconData icon;

  const LoadingOverlay({
    super.key,
    required this.opacityAnimation,
    required this.iconScaleAnimation,
    required this.gradient,
    required this.buttonText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = gradient.colors.isNotEmpty ? gradient.colors.first : const Color(0xFFFF0055);

    return Positioned.fill(
      child: FadeTransition(
        opacity: opacityAnimation,
        child: Container(
          color: const Color(0xFF0B0B1A).withOpacity(0.95), 
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    ScaleTransition(
                      scale: iconScaleAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: Icon(
                          icon,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 30),
                Text(
                  '$buttonText...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: mainColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
