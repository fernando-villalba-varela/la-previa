import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/participants_viewmodel.dart';
import '../../../../../core/models/player.dart';

class PlayerCardWidget extends StatelessWidget {
  final int index;
  final List<Player> players;

  const PlayerCardWidget({
    super.key,
    required this.index,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ParticipantsViewmodel>(
      context,
      listen: false,
    );
    final player = players[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => viewModel.onAvatarTap(index),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: (player.imagen != null || player.avatar != null)
                    ? ClipOval(
                        child: player.imagen != null
                            ? Image.file(
                                player.imagen!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.asset(
                                player.avatar!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      )
                    : CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.confirmDelete(index),
                child: Text(
                  player.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Icon(
              Icons.touch_app,
              color: Colors.white.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
