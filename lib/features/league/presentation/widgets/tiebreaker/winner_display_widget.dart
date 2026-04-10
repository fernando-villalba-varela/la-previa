import 'package:flutter/material.dart';
import 'package:drinkaholic/core/models/player.dart';

class WinnerDisplayWidget extends StatelessWidget {
  final Player winner;
  final bool isMVP;
  final bool isQuestionTiebreaker;
  final Animation<double> winnerScale;

  const WinnerDisplayWidget({
    super.key,
    required this.winner,
    required this.isMVP,
    required this.isQuestionTiebreaker,
    required this.winnerScale,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isQuestionTiebreaker
        ? const Color(0xFF00C9FF)
        : (isMVP ? const Color(0xFFFFD700) : const Color(0xFFFF0055));

    return ScaleTransition(
      scale: winnerScale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerAvatar(winner, size: 48),
            const SizedBox(width: 14),
            Text(
              winner.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(Player player, {double size = 40}) {
    ImageProvider? img;
    if (player.imagen != null && player.imagen!.existsSync()) {
      img = FileImage(player.imagen!);
    } else if (player.avatar != null && player.avatar!.startsWith('assets/')) {
      img = AssetImage(player.avatar!);
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: img,
      child: img == null
          ? Text(
              player.nombre.isNotEmpty ? player.nombre[0].toUpperCase() : '?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: size * 0.4),
            )
          : null,
    );
  }
}
