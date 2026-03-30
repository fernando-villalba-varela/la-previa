import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

class HomeHeader extends StatelessWidget {
  final double screenWidth;

  const HomeHeader({
    super.key,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo above title
          Image.asset(
            'assets/images/logo.png',
            width: min(screenWidth * 0.4, 180),
            height: min(screenWidth * 0.4, 180),
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),

          // Title with epic styling connected to background
          _buildTitleWithGradient(screenWidth),

          SizedBox(height: 6.h),
          Text(
            'Powered by',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xCCFFFFFF),
              letterSpacing: 1.8,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 16.h),

          // Promo images
          _buildPromoImages(screenWidth),
        ],
      ),
    );
  }

  Widget _buildTitleWithGradient(double screenWidth) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outline stroke for readability
        Text(
          'LA PREVIA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: min(screenWidth * 0.12, 88),
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black.withOpacity(0.7),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00FFFF), // Electric Cyan
              Color(0xFFFF0055), // Crimson Fiesta
              Color(0xFFFF8C00), // Fiery Orange
            ],
            stops: [0.1, 0.5, 0.9],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'LA PREVIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: min(screenWidth * 0.12, 88),
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(-2, -2),
                ),
                Shadow(
                  color: const Color(0xFFFF0055).withOpacity(0.6),
                  blurRadius: 25,
                  offset: const Offset(0, 2),
                ),
                Shadow(
                  color: const Color(0xFFFF8C00).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(2, 2),
                ),
                const Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(2, 4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoImages(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/promo.png',
          width: min(screenWidth * 0.25, 90),
          fit: BoxFit.contain,
        ),
        SizedBox(width: 10.w),
        Image.asset(
          'assets/images/promo2.png',
          width: min(screenWidth * 0.25, 90),
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
