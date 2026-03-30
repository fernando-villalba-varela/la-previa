import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/models/player.dart';
import '../../../../../../core/services/language_service.dart';
import 'player_avatar.dart';

class MVPCard extends StatelessWidget {
  final Player player;
  final int drinks;
  final Animation<double> glowAnimation;
  final bool isSmallScreen;

  const MVPCard({
    super.key,
    required this.player,
    required this.drinks,
    required this.glowAnimation,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = isSmallScreen ? 50.0 : 60.0;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isSmallScreen ? 12.0 : 14.0;
    final playerNameFontSize = isSmallScreen ? 18.0 : 22.0;
    final drinksFontSize = isSmallScreen ? 13.0 : 15.0;

    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700).withOpacity(0.3),
                const Color(0xFFFFD700).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700)
                    .withOpacity(0.25 + 0.35 * glowAnimation.value),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              PlayerAvatar(player: player, size: avatarSize),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Provider.of<LanguageService>(context)
                          .translate('mvp_title'),
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Text(
                      player.nombre,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: playerNameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      '$drinks ${Provider.of<LanguageService>(context).translate('drinks_count_suffix')}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: drinksFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
