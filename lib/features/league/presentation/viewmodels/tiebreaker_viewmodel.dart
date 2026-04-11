import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui' as ui;
import '../../../../core/models/player.dart';

class TiebreakerViewModel extends ChangeNotifier {
  final List<Player> tiedPlayers;
  final int tiedScore;
  final String? currentQuestion;
  final int drinksAmount;

  // Estado
  bool _isSpinning = false;
  bool _hasSpun = false;
  Player? _winner;
  double _finalBottleAngle = 0.0;
  final Map<String, ui.Image?> _playerImages = {};

  // Colores fijos
  late List<Color> _fixedColors;

  TiebreakerViewModel({
    required this.tiedPlayers,
    required this.tiedScore,
    this.currentQuestion,
    this.drinksAmount = 1,
  }) {
    _initializeFixedColors();
    _loadPlayerImages();
  }

  // Getters
  bool get isSpinning => _isSpinning;
  bool get hasSpun => _hasSpun;
  Player? get winner => _winner;
  double get finalBottleAngle => _finalBottleAngle;
  Map<String, ui.Image?> get playerImages => _playerImages;
  List<Color> get fixedColors => _fixedColors;

  void _initializeFixedColors() {
    _fixedColors = [
      const Color(0xFFFF0055),  // magenta app
      const Color(0xFF00C9FF),  // cyan app
      const Color(0xFF8B5CF6),  // violeta
      const Color(0xFFF59E0B),  // ámbar
      const Color(0xFF10B981),  // esmeralda
      const Color(0xFFEC4899),  // rosa
      const Color(0xFF06B6D4),  // teal claro
      const Color(0xFFEF4444),  // rojo suave
    ];
  }

  Future<void> _loadPlayerImages() async {
    for (final player in tiedPlayers) {
      ui.Image? image;

      try {
        if (player.imagen != null && player.imagen!.existsSync()) {
          final bytes = await player.imagen!.readAsBytes();
          image = await decodeImageFromList(bytes);
        } else if (player.avatar != null && player.avatar!.startsWith('assets/')) {
          final data = await rootBundle.load(player.avatar!);
          final bytes = data.buffer.asUint8List();
          image = await decodeImageFromList(bytes);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error cargando imagen para ${player.nombre}: $e');
        }
      }

      _playerImages[player.nombre] = image;
    }

    notifyListeners();
  }

  void calculateSpinAngle() {
    if (_isSpinning || _hasSpun) return;

    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    final random = Random();
    
    // 1. Elegir ganador primero en código
    final playerCount = tiedPlayers.length;
    final winnerIndex = random.nextInt(playerCount);
    
    // 2. Calcular ángulo que caiga siempre en su porción (evitando bordes)
    final anglePerSection = (2 * pi) / playerCount;
    final offsetWithinSlice = anglePerSection * (0.2 + 0.6 * random.nextDouble());
    final randomAngle = (playerCount - winnerIndex) * anglePerSection - offsetWithinSlice;

    final extraSpins = 4 + random.nextInt(4);
    _finalBottleAngle = randomAngle + (extraSpins * 2 * pi);

    _isSpinning = true;
    _winner = null;
    notifyListeners();
  }

  void finalizeWinner() {
    final playerCount = tiedPlayers.length;
    final anglePerSection = (2 * pi) / playerCount;
    final sectionIndex = ((-_finalBottleAngle) / anglePerSection).floor() % playerCount;

    _winner = tiedPlayers[sectionIndex];
    _isSpinning = false;
    _hasSpun = true;

    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    notifyListeners();
  }

  int getDrinksFromQuestion() {
    return drinksAmount;
  }
}
