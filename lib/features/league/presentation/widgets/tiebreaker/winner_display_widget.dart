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
    return ScaleTransition(
      scale: winnerScale,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isQuestionTiebreaker
                  ? Colors.purple
                  : (isMVP ? const Color(0xFFFFD700) : const Color(0xFF8B4513)))
              .withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isQuestionTiebreaker
                ? Colors.purple
                : (isMVP ? const Color(0xFFFFD700) : const Color(0xFF8B4513)),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerAvatar(winner, size: 50),
            const SizedBox(width: 16),
            Text(
              winner.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
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
