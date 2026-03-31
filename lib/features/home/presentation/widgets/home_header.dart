import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';

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
          SizedBox(height: 60.h), // Top padding for the new top bar
          // Logo above title
          Image.asset(
            'assets/images/logo.png',
            width: min(screenWidth * 0.4, 180),
            height: min(screenWidth * 0.4, 180),
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),

          // Title with neon glow
          _buildNeonTitle(screenWidth),

          SizedBox(height: 6.h),
          Text(
            context.read<LanguageService>().translate('ignite_your_night'),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xCCFFFFFF),
              letterSpacing: 4.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildNeonTitle(double screenWidth) {
    return Text(
      'LA PREVIA',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: min(screenWidth * 0.12, 88),
        fontWeight: FontWeight.w900,
        letterSpacing: 8,
        color: Colors.white,
        shadows: [
          Shadow(
            color: const Color(0xFFFF0055).withOpacity(0.8),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
          Shadow(
            color: const Color(0xFFFF0055).withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 0),
          ),
          Shadow(
            color: const Color(0xFFFF0055).withOpacity(0.3),
            blurRadius: 45,
            offset: const Offset(0, 0),
          ),
          const Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(2, 4)),
        ],
      ),
    );
  }
}
