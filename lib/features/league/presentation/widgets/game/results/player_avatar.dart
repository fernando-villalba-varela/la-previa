import 'package:flutter/material.dart';
import '../../../../../../core/models/player.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
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
