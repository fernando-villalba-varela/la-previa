import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingParticle extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final int index;

  const FloatingParticle({super.key, required this.screenWidth, required this.screenHeight, required this.index});

  @override
  State<FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.index); 
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + rng.nextInt(4000)),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcular propiedades permanentemente en build para evitar nulos por Hot Reload
    final rng = math.Random(widget.index);
    final size = 4.0 + rng.nextInt(8);
    final left = rng.nextDouble() * widget.screenWidth;
    final startTop = rng.nextDouble() * widget.screenHeight;
    final baseOpacity = 0.1 + rng.nextDouble() * 0.4;
    
    final colorVal = rng.nextInt(3);
    final particleColor = colorVal == 0 
        ? const Color(0xFF00FFFF) 
        : colorVal == 1 
            ? const Color(0xFFFF0055) 
            : const Color(0xFFFF8C00);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final yOffset = startTop - (progress * 200);
        
        double currentOpacity = baseOpacity;
        if (progress < 0.2) {
          currentOpacity = baseOpacity * (progress / 0.2); 
        } else if (progress > 0.8) {
          currentOpacity = baseOpacity * ((1.0 - progress) / 0.2); 
        }

        return Positioned(
          left: left,
          top: yOffset,
          child: Opacity(
            opacity: currentOpacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: particleColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: particleColor.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}



