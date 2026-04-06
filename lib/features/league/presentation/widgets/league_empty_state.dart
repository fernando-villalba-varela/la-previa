import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/language_service.dart';

class LeagueEmptyState extends StatelessWidget {
  const LeagueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_drink, size: 110, color: const Color(0xFF00C9FF)), // Neon Cyan
          const SizedBox(height: 34),
          Text(
            Provider.of<LanguageService>(context).translate('empty_league_title'),
            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: .5, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              Provider.of<LanguageService>(context).translate('empty_league_subtitle'),
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


