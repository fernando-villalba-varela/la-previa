import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/models/player.dart';
import '../../../../../../core/services/language_service.dart';
import 'player_avatar.dart';

class RatitaCard extends StatelessWidget {
  final Player player;
  final int drinks;
  final Animation<double> glowAnimation;
  final bool isSmallScreen;

  const RatitaCard({
    super.key,
    required this.player,
    required this.drinks,
    required this.glowAnimation,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = isSmallScreen ? 40.0 : 48.0;
    final padding = isSmallScreen ? 10.0 : 12.0;
    final titleFontSize = isSmallScreen ? 11.0 : 13.0;
    final playerNameFontSize = isSmallScreen ? 15.0 : 18.0;
    final drinksFontSize = isSmallScreen ? 12.0 : 14.0;

    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 98, 46, 33).withOpacity(0.3),
                const Color.fromARGB(255, 98, 46, 33).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(255, 98, 46, 33), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B4513)
                    .withOpacity(0.20 + 0.30 * glowAnimation.value),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              PlayerAvatar(player: player, size: avatarSize),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Provider.of<LanguageService>(context)
                          .translate('rat_title'),
                      style: TextStyle(
                        color: const Color.fromARGB(255, 98, 46, 33),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
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
