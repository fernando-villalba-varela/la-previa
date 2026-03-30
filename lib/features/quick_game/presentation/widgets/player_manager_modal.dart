import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/player.dart';
import '../../../../core/services/language_service.dart';

/// Modal para editar la lista de jugadores durante el juego
class PlayerManagerModal extends StatefulWidget {
  final List<Player> initialPlayers;
  final Function(List<Player>) onPlayersUpdated;

  const PlayerManagerModal({
    super.key,
    required this.initialPlayers,
    required this.onPlayersUpdated,
  });

  @override
  State<PlayerManagerModal> createState() => _PlayerManagerModalState();
}

class _PlayerManagerModalState extends State<PlayerManagerModal> {
  late List<Player> _tempPlayers;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _tempPlayers = List<Player>.from(widget.initialPlayers);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _nextPlayerId(List<Player> list) {
    final ids = list.map((e) => e.id);
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  void _addPlayer(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _tempPlayers.add(
        Player(
          id: _nextPlayerId(_tempPlayers),
          nombre: name.trim(),
        ),
      );
    });
    _controller.clear();
  }

  void _removePlayer(int index) {
    setState(() {
      _tempPlayers.removeAt(index);
    });
  }

  Future<void> _renamePlayer(int index) async {
    final player = _tempPlayers[index];
    final tc = TextEditingController(text: player.nombre);
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(languageService.translate('rename_player_title')),
          content: TextField(
            controller: tc,
            autofocus: true,
            decoration: InputDecoration(
              hintText: languageService.translate('name_hint'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(languageService.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tc.text.trim()),
              child: Text(languageService.translate('save_button')),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _tempPlayers[index] = Player(
          id: player.id,
          nombre: newName,
          imagen: player.imagen,
          avatar: player.avatar,
        );
      });
    }
    tc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3E),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white24),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        languageService.translate('edit_players_title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: languageService
                              .translate('add_player_dots_hint'),
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white24,
                            ),
                          ),
                        ),
                        onSubmitted: (value) => _addPlayer(value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _addPlayer(_controller.text),
                      child: Text(
                        languageService.translate('add_button'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ..._buildPlayersList(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onPlayersUpdated(_tempPlayers);
                    },
                    child: Text(
                      languageService.translate('done_button'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPlayersList() {
    return _tempPlayers.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      return ListTile(
        title: Text(
          player.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white70,
              ),
              onPressed: () => _renamePlayer(index),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              onPressed: () => _removePlayer(index),
            ),
          ],
        ),
      );
    }).toList();
  }
}
