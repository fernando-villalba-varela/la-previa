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
    return Positioned.fill(
      child: FadeTransition(
        opacity: opacityAnimation,
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: iconScaleAnimation,
                  child: Icon(
                    icon,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 60),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  '$buttonText...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
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
