import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/consent_and_ad_service.dart';
import 'home_game_card.dart';

class HomeButtonsSection extends StatelessWidget {
  final VoidCallback onQuickGamePressed;
  final VoidCallback onLeaguePressed;
  final VoidCallback onElixirsPressed;

  const HomeButtonsSection({
    super.key,
    required this.onQuickGamePressed,
    required this.onLeaguePressed,
    required this.onElixirsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card — Partida Rápida (Coral / Salmon)
        HomeGameCard(
          title: lang.translate('play_quick'),
          subtitle: lang.translate('quick_game_subtitle'),
          icon: Icons.rocket_launch_rounded,
          backgroundIcon: Icons.rocket_launch_rounded,
          gradientColors: const [Color(0xFFFF7B7B), Color(0xFFFFA07A)],
          textColor: const Color(0xFF1A0A0A),
          onTap: onQuickGamePressed,
          height: 165,
        ),

        const SizedBox(height: 16),

        // Card — La Liga (Yellow)
        HomeGameCard(
          title: lang.translate('play_league'),
          subtitle: lang.translate('league_subtitle'),
          icon: Icons.emoji_events_rounded,
          backgroundIcon: Icons.emoji_events_rounded,
          gradientColors: const [Color(0xFFFFD700), Color(0xFFFFE44D)],
          textColor: const Color(0xFF1A1500),
          onTap: onLeaguePressed,
          height: 165,
        ),

        const SizedBox(height: 16),

        // Card — Recarga Elixir (Compact, dark glassmorphism)
        HomeGameCard(
          title: lang.translate('menu_reload_elixirs').toUpperCase(),
          subtitle: lang.translate('elixir_subtitle'),
          icon: Icons.science_rounded,
          backgroundIcon: Icons.science_rounded,
          gradientColors: [
            const Color(0xFF1E1E3A).withOpacity(0.9),
            const Color(0xFF2A2A4A).withOpacity(0.9),
          ],
          textColor: Colors.white,
          onTap: onElixirsPressed,
          height: 80,
          compact: true,
        ),

        const SizedBox(height: 20),
        const PrivacyOptionsButton(),
      ],
    );
  }
}
