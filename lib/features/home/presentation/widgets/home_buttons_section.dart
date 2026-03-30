import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/consent_and_ad_service.dart';
import '../../../../core/presentation/components/drinkaholic_button.dart';
import '../viewmodels/home_viewmodel.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickGameButton(context),
          SizedBox(height: 18.h),
          _buildLeagueButton(context),
          SizedBox(height: 18.h),
          _buildElixirsButton(context),
          SizedBox(height: 24.h),
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
    final text = languageService.translate('play_league');

    return DrinkaholicButton(
      onPressed: onLeaguePressed,
      label: text,
      icon: Icons.emoji_events,
      variant: DrinkaholicButtonVariant.secondary,
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
