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
    final vm = context.watch<LeagueDetailViewModel>();
    final lang = Provider.of<LanguageService>(context, listen: false);
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
            const Icon(Icons.people_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              lang.translate('no_players_title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              lang.translate('add_players_hint'),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Leyenda de iconos
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(icon: Icons.emoji_events, color: Colors.amber, label: lang.translate('stats_mvdp')),
              const SizedBox(width: 16),
              _LegendItem(icon: Icons.local_bar, color: Colors.cyanAccent, label: lang.translate('stats_drinks')),
              const SizedBox(width: 16),
              _LegendItem(emoji: '💩', color: Colors.pinkAccent, label: lang.translate('stats_ratita')),
              const SizedBox(width: 16),
              _LegendItem(icon: Icons.sports_esports, color: Colors.white70, label: lang.translate('stats_matches')),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 4),
        // Lista de jugadores
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (_, i) {
              final p = players[i];
              final img = _avatar(p.avatarPath);
              final pos = i + 1;
              final league = vm.league;
              final isMvpStreak = league.currentMvpStreak == p.playerId && league.mvpStreakCount >= 2;
              final isRatitaStreak = league.currentRatitaStreak == p.playerId && league.ratitaStreakCount >= 2;
              final hasBadge = pos == 1 || (pos == lastPos && lastPos > 1);

              final glowColor = pos == 1
                  ? Colors.amber
                  : (pos == lastPos && lastPos > 1)
                      ? const Color(0xFF8B5523)
                      : null;

              return DrinkaholicCard(
                padding: hasBadge
                    ? const EdgeInsets.fromLTRB(12, 16, 12, 10)
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                glowColor: glowColor,
                child: Row(
                  children: [
                    // Posición + Avatar
                    SizedBox(
                      width: 76,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#$pos',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: pos == 1 ? Colors.amber : Colors.white60,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: img,
                                child: img == null
                                    ? Text(
                                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              if (pos == 1)
                                const Positioned(
                                  top: -16,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text('🏆', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              if (pos == lastPos && lastPos > 1)
                                const Positioned(
                                  top: -16,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text('🐭', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Nombre + stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isMvpStreak) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.local_fire_department, size: 13, color: Colors.redAccent),
                                Text('${league.mvpStreakCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                              if (isRatitaStreak) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.pets, size: 13, color: Colors.pinkAccent),
                                Text('${league.ratitaStreakCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _StatItem(icon: Icons.emoji_events, color: Colors.amber, value: p.mvdpCount),
                              const SizedBox(width: 14),
                              _StatItem(icon: Icons.local_bar, color: Colors.cyanAccent, value: p.totalDrinks),
                              const SizedBox(width: 14),
                              _StatItem(emoji: '💩', color: Colors.pinkAccent, value: p.ratitaCount),
                              const SizedBox(width: 14),
                              _StatItem(icon: Icons.sports_esports, color: Colors.white70, value: p.gamesPlayed),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    _PointsBadge(points: p.points),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final Color color;
  final String label;

  const _LegendItem({this.icon, this.emoji, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null)
          Text(emoji!, style: const TextStyle(fontSize: 13))
        else
          Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final Color color;
  final int value;

  const _StatItem({this.icon, this.emoji, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null)
          Text(emoji!, style: const TextStyle(fontSize: 14))
        else
          Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text('$value', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final int points;

  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    final isNegative = points < 0;
    final isZero = points == 0;
    final color = isNegative ? Colors.redAccent : isZero ? Colors.amber : const Color(0xFF00C9FF);
    final sign = isNegative || isZero ? '' : '+';

    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.7), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$sign$points',
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 17),
            textAlign: TextAlign.center,
          ),
          Text(
            'pts',
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
