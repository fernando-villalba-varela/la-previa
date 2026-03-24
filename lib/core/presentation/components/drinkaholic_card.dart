import 'package:flutter/material.dart';
import 'dart:ui';

class DrinkaholicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const DrinkaholicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E2C).withOpacity(0.6),
            const Color(0xFF0B0B1A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BE2).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

