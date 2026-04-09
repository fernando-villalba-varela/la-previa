import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/pack_service.dart';
import '../../../../core/services/consent_and_ad_service.dart';
import '../../../../core/presentation/components/drinkaholic_button.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        left: 32.w,
        right: 32.w,
        top: 20.h,
        bottom: 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickGameButton(context),
          SizedBox(height: 18.h),
          _buildLeagueButton(context),
          SizedBox(height: 18.h),
          _buildElixirsButton(context),
          SizedBox(height: 12.h),
          const PrivacyOptionsButton(),
        ],
      ),
    );
  }

  Widget _buildQuickGameButton(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final text = languageService.translate('play_quick');

    return DrinkaholicButton(
      onPressed: onQuickGamePressed,
      label: text,
      icon: Icons.flash_on,
      variant: DrinkaholicButtonVariant.primary,
    );
  }

  Widget _buildLeagueButton(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isPremium = Provider.of<PackService>(context).isPremium;
    final text = languageService.translate('play_league');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Botón con opacidad reducida si no es premium
        Opacity(
          opacity: isPremium ? 1.0 : 0.55,
          child: DrinkaholicButton(
            onPressed: onLeaguePressed,
            label: text,
            icon: Icons.emoji_events,
            variant: DrinkaholicButtonVariant.secondary,
          ),
        ),
        // Badge de candado en esquina superior derecha
        if (!isPremium)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B1A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.lock, color: Colors.white70, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildElixirsButton(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final text = languageService.translate('menu_reload_elixirs');

    return DrinkaholicButton(
      onPressed: onElixirsPressed,
      label: text,
      icon: Icons.local_drink,
      variant: DrinkaholicButtonVariant.outline,
    );
  }
}
