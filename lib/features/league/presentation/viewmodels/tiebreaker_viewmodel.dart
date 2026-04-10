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
      Colors.red.withOpacity(0.7),
      Colors.blue.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.pink.withOpacity(0.7),
      Colors.teal.withOpacity(0.7),
      Colors.amber.withOpacity(0.7),
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
    final randomAngle = (winnerIndex * anglePerSection) + offsetWithinSlice;

    final extraSpins = 4 + random.nextInt(4);
    _finalBottleAngle = randomAngle + (extraSpins * 2 * pi);

    _isSpinning = true;
    _winner = null;
    notifyListeners();
  }

  void finalizeWinner() {
    final playerCount = tiedPlayers.length;
    final normalizedAngle = _finalBottleAngle % (2 * pi);
    final anglePerSection = (2 * pi) / playerCount;
    final sectionIndex = (normalizedAngle / anglePerSection).floor() % playerCount;

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

  String extractQuestionPart() {
    if (currentQuestion == null || currentQuestion!.isEmpty) {
      return '';
    }

    final question = currentQuestion!.trim();

    final patterns = [
      RegExp(r'^a\s+la\s+de\s+\d+\s+(?:todos\s+)?señalan?\s+al?\s+jugador(?:a)?\s+que\s+sea\s+m[aá]s\s+probable\s+que\s+',
          caseSensitive: false),
      RegExp(r'^a\s+la\s+de\s+\d+,?\s+(?:todos\s+)?señalen?\s+a\s+quien\s+se(?:a|rá)\s+m[aá]s\s+probable\s+que\s+',
          caseSensitive: false),
      RegExp(r'^a\s+(?:la\s+)?cuenta?\s+de\s+\d+,?\s+(?:todos\s+)?apunten?\s+(?:a\s+)?quien(?:es)?\s+(?:crean|sea)\s+que\s+',
          caseSensitive: false),
      RegExp(r'^a\s+la\s+de\s+\d+,?\s+(?:todos\s+)?señalen?\s+a\s+(?:la\s+)?persona?\s+m[aá]s\s+propensa?\s+a\s+',
          caseSensitive: false),
      RegExp(r'^(?:a\s+la\s+de\s+\d+\s+)?(?:todos\s+)?(?:cualquiera|el\s+que|quien|aquello\s+que)\s+', caseSensitive: false),
    ];

    String result = question;

    for (final pattern in patterns) {
      final match = pattern.firstMatch(result);
      if (match != null) {
        result = result.substring(match.end).trim();
        break;
      }
    }

    result = result.replaceAll(RegExp(r';\s*(?:ese\s+)?jugador(?:a)?\s+beb[eé].*$', caseSensitive: false), '');
    result = result.replaceAll(RegExp(r',\s*(?:ese\s+)?jugador(?:a)?\s+beb[eé].*$', caseSensitive: false), '');
    result = result.replaceAll(
        RegExp(r'[;,]\s*(?:ese|esa)\s+(?:jugador(?:a)?|persona)\s+beb[eé]r?a?.*$', caseSensitive: false), '');
    result = result.replaceAll(RegExp(r';\s*quien.*$', caseSensitive: false), '');
    result = result.replaceAll(RegExp(r'\s+(?:tragos?|trago).*$', caseSensitive: false), '').trim();

    result = _transformGrammatically(result);

    return result;
  }

  String _transformGrammatically(String text) {
    final transformations = <RegExp, String>{
      RegExp(r'\bllegue\b', caseSensitive: false): 'llegarás',
      RegExp(r'\bse\s+quede\b', caseSensitive: false): 'te quedarás',
      RegExp(r'\bresponda\b', caseSensitive: false): 'responderás',
      RegExp(r'\bse\s+case\b', caseSensitive: false): 'te casarás',
      RegExp(r'\bolvide\b', caseSensitive: false): 'olvidarás',
      RegExp(r'\bhaga\b', caseSensitive: false): 'harás',
      RegExp(r'\bse\s+pierda\b', caseSensitive: false): 'te perderás',
      RegExp(r'\borganice\b', caseSensitive: false): 'organizarás',
      RegExp(r'\brompa\b', caseSensitive: false): 'romperás',
      RegExp(r'\bmande\b', caseSensitive: false): 'mandarás',
      RegExp(r'\bllore\b', caseSensitive: false): 'llorarás',
      RegExp(r'\bligue\b', caseSensitive: false): 'ligarás',
      RegExp(r'\bgane\b', caseSensitive: false): 'ganarás',
      RegExp(r'\bse\s+vaya\b', caseSensitive: false): 'te irás',
      RegExp(r'\bse\s+haga\b', caseSensitive: false): 'te harás',
      RegExp(r'\btenga\b', caseSensitive: false): 'tendrás',
      RegExp(r'\badopte\b', caseSensitive: false): 'adoptarás',
      RegExp(r'\bse\s+tatúe\b', caseSensitive: false): 'te tatúarás',
      RegExp(r'\bcoma\b', caseSensitive: false): 'comerás',
      RegExp(r'\bcante\b', caseSensitive: false): 'cantarás',
      RegExp(r'\bpierda\b', caseSensitive: false): 'perderás',
      RegExp(r'\bse\s+cambie\b', caseSensitive: false): 'te cambiarás',
      RegExp(r'\bsuba\b', caseSensitive: false): 'subirás',
      RegExp(r'\bhaga\s+un\s+maratón\b', caseSensitive: false): 'harás un maratón',
      RegExp(r'\bcocine\b', caseSensitive: false): 'cocinarás',
      RegExp(r'\bse\s+apunte\b', caseSensitive: false): 'te apuntarás',
      RegExp(r'\bsea\b', caseSensitive: false): 'serás',
      RegExp(r'\bse\s+rompa\b', caseSensitive: false): 'se te romperá',
      RegExp(r'\bolvide\s+dónde\b', caseSensitive: false): 'olvidarás dónde',
      RegExp(r'\bpierda\s+la\s+cartera\b', caseSensitive: false): 'perderás la cartera',
      RegExp(r'\bhaga\s+match\b', caseSensitive: false): 'harás match',
      RegExp(r'\bse\s+haga\s+un\s+piercing\b', caseSensitive: false): 'te harás un piercing',
      RegExp(r'\bcante\s+a\s+gritos\b', caseSensitive: false): 'cantarás a gritos',
      RegExp(r'\bse\s+duerma\b', caseSensitive: false): 'te dormirás',
      RegExp(r'\brobe\b', caseSensitive: false): 'robarás',
      RegExp(r'\badopte\s+un\s+gato\b', caseSensitive: false): 'adoptarás un gato',
      RegExp(r'\bse\s+haga\s+vegano\b', caseSensitive: false): 'te harás vegano',
      RegExp(r'\bllore\s+de\s+la\s+risa\b', caseSensitive: false): 'llorarás de la risa',
      RegExp(r'\bcuente\b', caseSensitive: false): 'contarás',
      RegExp(r'\bcambie\b', caseSensitive: false): 'cambiarás',
      RegExp(r'\bdeje\b', caseSensitive: false): 'dejarás',
      RegExp(r'\babra\b', caseSensitive: false): 'abrirás',
      RegExp(r'\bse\s+enamore\b', caseSensitive: false): 'te enamorarás',
      RegExp(r'\bhaga\s+ghosting\b', caseSensitive: false): 'harás ghosting',
      RegExp(r'\bvuelva\b', caseSensitive: false): 'volverás',
      RegExp(r'\bse\s+olvide\b', caseSensitive: false): 'se te olvidará',
    };

    String result = text;
    transformations.forEach((pattern, replacement) {
      result = result.replaceAll(pattern, replacement);
    });

    return result;
  }
}
