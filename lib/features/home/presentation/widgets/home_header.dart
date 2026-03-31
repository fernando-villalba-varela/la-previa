import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final lang = context.watch<LanguageService>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero Title — Line 1 (white)
            Text(
              lang.translate('home_hero_1'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.075 > 32 ? 32 : screenWidth * 0.075,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                height: 1.2,
              ),
            ),
            // Hero Title — Line 2 (magenta italic)
            Text(
              lang.translate('home_hero_2'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.085 > 38 ? 38 : screenWidth * 0.085,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFFF0055),
                letterSpacing: 2,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF0055).withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
