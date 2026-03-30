import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/models/player.dart';
import '../../../../../../core/services/language_service.dart';
import 'ratita_card.dart';
import 'player_avatar.dart';

class GameStatsSection extends StatelessWidget {
  final Map<int, int> playerDrinks;
  final List<Player> players;
  final int maxRounds;
  final Player ratitaPlayer;
  final Animation<double> glowAnimation;
  final bool isSmallScreen;

  const GameStatsSection({
    super.key,
    required this.playerDrinks,
    required this.players,
    required this.maxRounds,
    required this.ratitaPlayer,
    required this.glowAnimation,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final sectionTitleFontSize = isSmallScreen ? 15.0 : 18.0;
    final statsFontSize = isSmallScreen ? 13.0 : 16.0;

    // Ordenar jugadores por cantidad de tragos (de más a menos)
    final sortedPlayers = List<MapEntry<int, int>>.from(playerDrinks.entries)
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Provider.of<LanguageService>(context)
                .translate('game_statistics_title'),
            style: TextStyle(
              color: Colors.white,
              fontSize: sectionTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ...sortedPlayers.map((entry) {
            final playerId = entry.key;
            final drinks = entry.value;
            final player = players.firstWhere(
              (p) => p.id == playerId,
              orElse: () => players.first,
            );

            final avatarSize = isSmallScreen ? 28.0 : 32.0;
            final drinkIconSize = isSmallScreen ? 14.0 : 16.0;

            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              child: Row(
                children: [
                  PlayerAvatar(player: player, size: avatarSize),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      player.nombre,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: statsFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C9FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_drink,
                          color: const Color(0xFF00C9FF),
                          size: drinkIconSize,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$drinks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: statsFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: isSmallScreen ? 12 : 16),
          RatitaCard(
            player: ratitaPlayer,
            drinks: playerDrinks[ratitaPlayer.id] ?? 0,
            glowAnimation: glowAnimation,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}
