import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/language_service.dart';
import '../../../presentation/viewmodels/league_detail_viewmodel.dart';
import 'package:drinkaholic/core/presentation/components/drinkaholic_card.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  ImageProvider? _avatar(String? path) {
    if (path == null) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    final f = File(path);
    if (f.existsSync()) return FileImage(f);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<LeagueDetailViewModel>();
    final players = [...vm.league.players]
      ..sort((a, b) {
        final pointsComparison = b.points.compareTo(a.points);
        if (pointsComparison != 0) return pointsComparison;
        return b.totalDrinks.compareTo(a.totalDrinks);
      });
    final lastPos = players.length;

    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              Provider.of<LanguageService>(context).translate('no_players_title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              Provider.of<LanguageService>(context).translate('add_players_hint'),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (_, i) {
        final p = players[i];
        final img = _avatar(p.avatarPath);
        final pos = i + 1;
        final league = vm.league;
        final isMvpStreak = league.currentMvpStreak == p.playerId && league.mvpStreakCount >= 2;
        final isRatitaStreak = league.currentRatitaStreak == p.playerId && league.ratitaStreakCount >= 2;

        return DrinkaholicCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: SizedBox(
              width: 84,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#$pos',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: pos == 1 ? Colors.amber : Colors.white, // ← cambiado
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        backgroundImage: img,
                        child: img == null
                            ? Text(
                                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      if (pos == 1)
                        Positioned(
                          top: -30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              '🏆',
                              style: TextStyle(
                                fontSize: 24,
                                shadows: const [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                            ),
                          ),
                        ),
                      if (pos == lastPos && lastPos > 1)
                        Positioned(
                          top: -23,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              '🐭',
                              style: TextStyle(
                                fontSize: 20,
                                shadows: const [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isMvpStreak)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 12, color: Colors.redAccent),
                        const SizedBox(width: 2),
                        Text(
                          '${league.mvpStreakCount}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                if (isRatitaStreak)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pets, size: 12, color: Colors.pink),
                        const SizedBox(width: 2),
                        Text(
                          '${league.ratitaStreakCount}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              'MVDP: ${p.mvdpCount} | Tragos: ${p.totalDrinks} | Ratita: ${p.ratitaCount} | Partidas: ${p.gamesPlayed}',
              style: const TextStyle(color: Colors.white70), // ← cambiado
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(0x14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withAlpha(0x59)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${p.points} pts',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), // ← cambiado
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}