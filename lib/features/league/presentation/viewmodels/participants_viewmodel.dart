import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';

class ParticipantsViewmodel extends ChangeNotifier {
  BuildContext? context;

  final List<Player> _players = [];

  int _nextPlayerId = 1;
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Getters
  List<Player> get players => _players;
  TextEditingController get controller => _controller;
  ImagePicker get picker => _picker;
  // Setters
  set players(List<Player> value) {
    _players
      ..clear()
      ..addAll(value);
    notifyListeners();
  }

  set controller(TextEditingController value) {
    // No es común cambiar el controller, pero si lo necesitas:
    // _controller = value; // Si _controller no es final
    notifyListeners();
  }

  set picker(ImagePicker value) {
    // No es común cambiar el picker, pero si lo necesitas:
    // _picker = value; // Si _picker no es final
    notifyListeners();
  }

  void addPlayer() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      _players.add(Player(id: _nextPlayerId++, nombre: name));
      _controller.clear();
      notifyListeners();
    }
  }

  void removePlayer(int index) {
    final imagen = _players[index].imagen;
    if (imagen != null && imagen.existsSync()) {
      imagen.deleteSync();
    }
    _players.removeAt(index);
    notifyListeners();
  }

  void onAvatarTap(int index) {
    if (kDebugMode) {
      print('Avatar tap en $index');
    }
    if (_players[index].imagen == null && _players[index].avatar == null) {
      showAvatarOptions(index);
    } else {
      confirmDeletePhoto(index);
    }
  }

  void showAvatarOptions(int index) {
    final lang = Provider.of<LanguageService>(context!, listen: false);
    showDialog(
      context: context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B0B1A),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${lang.translate('select_avatar_title')} ${_players[index].nombre}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Opciones
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAvatarOption(
                      context: context,
                      icon: Icons.collections,
                      label: lang.translate('choose_avatar_option'),
                      onTap: () { Navigator.of(context).pop(); chooseAvatar(index); },
                    ),
                    const SizedBox(height: 8),
                    _buildAvatarOption(
                      context: context,
                      icon: Icons.camera_alt,
                      label: lang.translate('take_photo_option'),
                      onTap: () { Navigator.of(context).pop(); pickImage(index); },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(lang.translate('cancel'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption({required BuildContext context, required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A4E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00C9FF), size: 22),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
          ],
        ),
      ),
    );
  }

  Future<void> chooseAvatar(int index) async {
    List<String> avatarPaths = [];
    try {
      // Load avatars from our custom manifest
      final manifestContent = await rootBundle.loadString('assets/avatar_manifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      if (manifestMap.containsKey('avatars')) {
        avatarPaths = List<String>.from(manifestMap['avatars']);
      }
      
      // Sort for consistent order
      avatarPaths.sort();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading avatar_manifest.json: $e');
      }
      // Continue to fallback if empty
    }

    if (avatarPaths.isEmpty) {
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
           SnackBar(
            content: Text(Provider.of<LanguageService>(context!, listen: false).translate('no_avatars_found')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

      // Get list of already used avatars (excluding current player)
      final usedAvatars = _players
          .asMap()
          .entries
          .where((entry) => entry.key != index && entry.value.avatar != null)
          .map((entry) => entry.value.avatar!)
          .toSet();

      if (context != null) {
        final lang = Provider.of<LanguageService>(context!, listen: false);
        showDialog(
          context: context!,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B0B1A),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.face, color: Colors.white70, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${lang.translate('select_avatar_grid_title')} ${_players[index].nombre}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white70, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Grid
                  SizedBox(
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: avatarPaths.length,
                        itemBuilder: (context, avatarIndex) {
                          final avatarPath = avatarPaths[avatarIndex];
                          final isUsed = usedAvatars.contains(avatarPath);
                          final isCurrentlySelected = _players[index].avatar == avatarPath;

                          return GestureDetector(
                            onTap: isUsed && !isCurrentlySelected
                                ? null
                                : () {
                                    _players[index] = Player(
                                      id: _players[index].id,
                                      nombre: _players[index].nombre,
                                      avatar: avatarPath,
                                    );
                                    notifyListeners();
                                    Navigator.of(context).pop();
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrentlySelected
                                      ? const Color(0xFF00C9FF)
                                      : isUsed
                                      ? Colors.red.shade400
                                      : Colors.white.withOpacity(0.2),
                                  width: isCurrentlySelected || isUsed ? 3 : 1,
                                ),
                                boxShadow: isCurrentlySelected
                                    ? [BoxShadow(color: const Color(0xFF00C9FF).withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: ColorFiltered(
                                      colorFilter: isUsed && !isCurrentlySelected
                                          ? ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken)
                                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                      child: Image.asset(
                                        avatarPath,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                  if (isUsed && !isCurrentlySelected)
                                    const Center(child: Icon(Icons.block, color: Colors.redAccent, size: 32)),
                                  if (isCurrentlySelected)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(Icons.check_circle, color: Color(0xFF92FE9D), size: 20),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Cancelar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(lang.translate('cancel'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

  Future<void> pickImage(int index) async {
    if (kDebugMode) {
      print('Intentando pedir permiso de cámara');
    }
    final status = await Permission.camera.request();
    if (kDebugMode) {
      print('Permiso de cámara: $status');
    }
    if (status.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 60);
      if (kDebugMode) {
        print('Foto tomada: ${photo?.path}');
      }
      if (photo != null && context != null) {
        _players[index] = Player(id: _players[index].id, nombre: _players[index].nombre, imagen: File(photo.path));
        notifyListeners(); // Notifica a la UI el cambio
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(Provider.of<LanguageService>(context!, listen: false).translate('camera_permission_denied')),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void confirmDeletePhoto(int index) {
    showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0B1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          '${Provider.of<LanguageService>(context, listen: false).translate('confirm_delete_photo_content')} ${_players[index].nombre}?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('cancel'), style: const TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('delete'), style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              _players[index] = Player(id: _players[index].id, nombre: _players[index].nombre);
              notifyListeners(); // Notifica a la UI el cambio
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void confirmDelete(int index) {
    showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0B1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          '${Provider.of<LanguageService>(context, listen: false).translate('confirm_delete_player_content')} ${_players[index].nombre}?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('cancel'), style: const TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('delete'), style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              removePlayer(index); // Usa removePlayer que llama a notifyListeners()
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}


