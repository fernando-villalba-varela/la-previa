import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:math' as math show Random;
import 'package:provider/provider.dart';
import '../../../../core/models/question_generator.dart';
import '../../../../core/models/player.dart';
import '../../../../core/models/game_state.dart';
import '../../../../core/models/constant_challenge.dart';
import '../../../../core/models/constant_challenge_generator.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/event_generator.dart';
import '../../../../core/services/consent_and_ad_service.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/pack_service.dart';

/// ViewModel que gestiona toda la lógica del juego rápido.
/// Maneja: generación de desafíos, selección de jugadores, rondas,
/// eventos, retos constantes y modo endless.
class QuickGameViewModel extends ChangeNotifier {
  final BuildContext context;
  final List<Player> initialPlayers;

  // Estado de jugadores
  late List<Player> _players;
  final Map<int, int> _playerWeights = {}; // Pesos por playerId
  final Set<String> _usedQuestions = <String>{};

  // Estado del juego
  int _currentPlayerIndex = -1;
  int? _dualPlayerIndex;
  String _currentChallenge = '';
  String? _currentAnswer;
  String? _currentTemplateId;
  bool _gameStarted = false;
  int _currentRound = 1;
  bool _isCurrentChallengeConstant = false;
  bool _isEndlessMode = false;

  // Desafíos y eventos
  List<ConstantChallenge> _constantChallenges = [];
  ConstantChallengeEnd? _currentChallengeEnd;
  List<Event> _events = [];
  EventEnd? _currentEventEnd;

  final _interstitial = InterstitialAdManager();

  // Getters
  List<Player> get players => _players;
  int get currentPlayerIndex => _currentPlayerIndex;
  int? get dualPlayerIndex => _dualPlayerIndex;
  String get currentChallenge => _currentChallenge;
  String? get currentAnswer => _currentAnswer;
  String? get currentTemplateId => _currentTemplateId;
  bool get gameStarted => _gameStarted;
  int get currentRound => _currentRound;
  bool get isCurrentChallengeConstant => _isCurrentChallengeConstant;
  bool get isEndlessMode => _isEndlessMode;
  List<ConstantChallenge> get constantChallenges => _constantChallenges;
  ConstantChallengeEnd? get currentChallengeEnd => _currentChallengeEnd;
  List<Event> get events => _events;
  EventEnd? get currentEventEnd => _currentEventEnd;
  Map<int, int> get playerWeights => _playerWeights;

  QuickGameViewModel({
    required this.context,
    required this.initialPlayers,
  }) {
    _players = List<Player>.from(initialPlayers);
    _initializePlayerWeights();
    _interstitial.loadAd();
  }

  void _initializePlayerWeights() {
    for (final p in _players) {
      _playerWeights[p.id] = 0;
    }
  }

  /// Calcula el modificador de bebidas en modo endless
  int getEndlessModifier() {
    if (!_isEndlessMode || _currentRound < 125) return 0;
    return ((_currentRound - 100) / 25).floor();
  }

  /// Añade texto modificador al desafío si es necesario
  String appendModifierText(String originalText) {
    int extra = getEndlessModifier();
    if (extra > 0) {
      final modifier = Provider.of<LanguageService>(
        context,
        listen: false,
      ).translate('endless_modifier').replaceAll('{extra}', extra.toString());
      return '$originalText\n\n$modifier';
    }
    return originalText;
  }

  /// Inicializa el primer desafío del juego
  Future<void> initializeFirstChallenge() async {
    await _generateNewChallenge();

    final gameState = createGameState();
    if (!gameState.isChallengeForAll &&
        !_isGenericPlayerQuestion() &&
        !gameState.isDualChallenge) {
      _selectWeightedRandomPlayer();
    } else if (gameState.isChallengeForAll) {
      _currentPlayerIndex = -1;
      notifyListeners();
    }
  }

  /// Crea el estado actual del juego
  GameState createGameState() {
    String? dualPlayer1Name;
    String? dualPlayer2Name;

    if (_dualPlayerIndex != null && _currentPlayerIndex >= 0) {
      if (_currentPlayerIndex < _players.length) {
        dualPlayer1Name = _players[_currentPlayerIndex].nombre;
      }
      if (_dualPlayerIndex! < _players.length) {
        dualPlayer2Name = _players[_dualPlayerIndex!].nombre;
      }
    }

    return GameState(
      players: _players,
      currentPlayerIndex: _currentPlayerIndex,
      currentChallenge: _currentChallenge,
      currentAnswer: _currentAnswer,
      glowAnimation: AlwaysStoppedAnimation(1.0),
      playerWeights: _playerWeights,
      gameStarted: _gameStarted,
      currentGift: null,
      currentRound: _currentRound,
      constantChallenges: _constantChallenges,
      currentChallengeEnd: _currentChallengeEnd,
      events: _events,
      currentEventEnd: _currentEventEnd,
      dualPlayerIndex: _dualPlayerIndex,
      dualPlayer1Name: dualPlayer1Name,
      dualPlayer2Name: dualPlayer2Name,
      isCurrentChallengeConstant: _isCurrentChallengeConstant,
      currentTemplateId: _currentTemplateId,
    );
  }

  /// Verifica si la pregunta actual es genérica (asignada a un jugador específico)
  bool _isGenericPlayerQuestion() {
    if (_currentChallenge.isEmpty) return false;

    return _currentPlayerIndex >= 0 &&
        _currentPlayerIndex < _players.length &&
        (_currentChallenge.contains(
              '${_players[_currentPlayerIndex].nombre} bebe',
            ) ||
            _currentChallenge.contains(
              '${_players[_currentPlayerIndex].nombre} reparte',
            ) ||
            _currentChallenge.contains(
              '${_players[_currentPlayerIndex].nombre} responde',
            ) ||
            _currentChallenge.contains(
              '${_players[_currentPlayerIndex].nombre} confiesa',
            ));
  }

  /// Genera un nuevo desafío (normal o genérico)
  Future<void> _generateNewChallenge() async {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLocale.languageCode;

    if (Random().nextDouble() < 0.3 && _players.isNotEmpty) {
      // Pregunta genérica con jugador específico (30% probabilidad)
      final selectedPlayerIndex = Random().nextInt(_players.length);
      final selectedPlayer = _players[selectedPlayerIndex];

      var attempts = 0;
      GeneratedQuestion question;
      do {
        question = await QuestionGenerator.generateRandomQuestionForPlayer(
          selectedPlayer.nombre,
          language: languageCode,
          activePackIds: Provider.of<PackService>(context, listen: false).activePackIds.toList(),
        );
        attempts++;
      } while (_usedQuestions.contains(question.question) && attempts < 30);
      _usedQuestions.add(question.question);

      _currentChallenge = appendModifierText(question.question);
      _currentAnswer = question.answer;
      _currentTemplateId = question.templateId;
      _currentPlayerIndex = selectedPlayerIndex;
    } else {
      // Pregunta normal
      var attempts = 0;
      GeneratedQuestion question;
      do {
        question = await QuestionGenerator.generateRandomQuestion(
          language: languageCode,
          activePackIds: Provider.of<PackService>(context, listen: false).activePackIds.toList(),
        );
        attempts++;
      } while (_usedQuestions.contains(question.question) && attempts < 30);
      _usedQuestions.add(question.question);

      _currentChallenge = appendModifierText(question.question);
      _currentAnswer = question.answer;
      _currentTemplateId = question.templateId;
      _currentPlayerIndex = -1;
    }
    notifyListeners();
  }

  /// Selecciona un jugador aleatoriamente basado en pesos
  void _selectWeightedRandomPlayer() {
    final minWeight = _playerWeights.values.isEmpty
        ? 0
        : _playerWeights.values.reduce((a, b) => a < b ? a : b);

    final List<int> eligibleIndices = [];
    for (int i = 0; i < _players.length; i++) {
      final id = _players[i].id;
      final w = _playerWeights[id] ?? 0;
      if (w == minWeight) eligibleIndices.add(i);
    }

    if (eligibleIndices.length < (_players.length ~/ 2)) {
      for (int i = 0; i < _players.length; i++) {
        if (!eligibleIndices.contains(i)) {
          final id = _players[i].id;
          final w = _playerWeights[id] ?? 0;
          if (w == minWeight + 1) eligibleIndices.add(i);
        }
      }
    }

    if (eligibleIndices.isEmpty) {
      for (int i = 0; i < _players.length; i++) {
        eligibleIndices.add(i);
      }
    }

    final selectedIndex =
        eligibleIndices[Random().nextInt(eligibleIndices.length)];

    _currentPlayerIndex = selectedIndex;
    final pid = _players[selectedIndex].id;
    _playerWeights[pid] = (_playerWeights[pid] ?? 0) + 1;
    notifyListeners();
  }

  /// Selecciona dos jugadores diferentes aleatoriamente
  List<Player> _selectTwoRandomPlayers() {
    if (_players.length < 2) return [];

    List<Player> eligiblePlayers = [];

    int minWeight = _playerWeights.values.isEmpty
        ? 0
        : _playerWeights.values.reduce((a, b) => a < b ? a : b);

    for (final p in _players) {
      final weight = _playerWeights[p.id] ?? 0;
      if (weight <= minWeight + 1) {
        eligiblePlayers.add(p);
      }
    }

    if (eligiblePlayers.length < 2) {
      eligiblePlayers = List.from(_players);
    }

    eligiblePlayers.shuffle(math.Random());
    return eligiblePlayers.take(2).toList();
  }

  /// Genera un nuevo desafío dual (dos jugadores)
  Future<void> _generateNewDualChallenge() async {
    final selectedPlayers = _selectTwoRandomPlayers();
    if (selectedPlayers.length < 2) {
      await _generateNewChallenge();
      return;
    }

    final player1 = selectedPlayers[0];
    final player2 = selectedPlayers[1];

    var attempts = 0;
    GeneratedQuestion question;
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLocale.languageCode;
    do {
      question = await QuestionGenerator.generateRandomDualQuestion(
        player1.nombre,
        player2.nombre,
        language: languageCode,
        activePackIds: Provider.of<PackService>(context, listen: false).activePackIds.toList(),
      );
      attempts++;
    } while (_usedQuestions.contains(question.question) && attempts < 30);
    _usedQuestions.add(question.question);

    final player1Index = _players.indexOf(player1);
    final player2Index = _players.indexOf(player2);

    _currentChallenge = appendModifierText(question.question);
    _currentAnswer = question.answer;
    _currentTemplateId = question.templateId;
    _currentPlayerIndex = player1Index;
    _dualPlayerIndex = player2Index;

    final id1 = _players[_currentPlayerIndex].id;
    final id2 = _players[_dualPlayerIndex!].id;
    _playerWeights[id1] = (_playerWeights[id1] ?? 0) + 1;
    _playerWeights[id2] = (_playerWeights[id2] ?? 0) + 1;
    notifyListeners();
  }

  /// Genera un nuevo reto constante
  Future<void> _generateNewConstantChallenge() async {
    final eligiblePlayer =
        ConstantChallengeGenerator.selectPlayerForNewChallenge(
          _players,
          _constantChallenges
              .where((c) => c.isActiveAtRound(_currentRound))
              .toList(),
        );

    if (eligiblePlayer == null) {
      await _generateNewChallenge();
      return;
    }

    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLocale.languageCode;
    final constantChallenge =
        await ConstantChallengeGenerator.generateRandomConstantChallenge(
          eligiblePlayer,
          _currentRound,
          language: languageCode,
          activePackIds: Provider.of<PackService>(context, listen: false).activePackIds.toList(),
        );

    _constantChallenges.add(constantChallenge);
    _currentChallenge = appendModifierText(constantChallenge.description);
    _currentTemplateId = constantChallenge.metadata['templateId'] as String?;
    _currentAnswer = null;
    _currentPlayerIndex = _players.indexWhere(
      (p) => p.id == eligiblePlayer.id,
    );
    _isCurrentChallengeConstant = true;
    notifyListeners();
  }

  /// Genera un nuevo reto constante dual
  Future<void> _generateNewDualConstantChallenge() async {
    final selectedPlayers = _selectTwoRandomPlayers();
    if (selectedPlayers.length < 2) {
      await _generateNewConstantChallenge();
      return;
    }

    final player1 = selectedPlayers[0];
    final player2 = selectedPlayers[1];

    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLocale.languageCode;
    final constantChallenge =
        await ConstantChallengeGenerator.generateRandomDualConstantChallenge(
          player1,
          player2,
          _currentRound,
          language: languageCode,
          activePackIds: Provider.of<PackService>(context, listen: false).activePackIds.toList(),
        );

    _constantChallenges.add(constantChallenge);
    _currentChallenge = appendModifierText(constantChallenge.description);
    _currentTemplateId = constantChallenge.metadata['templateId'] as String?;
    _currentPlayerIndex = _players.indexOf(player1);
    _dualPlayerIndex = _players.indexOf(player2);
    notifyListeners();
  }

  /// Genera un nuevo evento
  Future<void> _generateNewEvent() async {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLocale.languageCode;
    final event = await EventGenerator.generateRandomEvent(
      _currentRound,
      language: languageCode,
      activePackIds: Provider.of<PackService>(context, listen: false).activePackIds.toList(),
    );

    _events.add(event);
    _currentChallenge = appendModifierText(
      '${event.typeIcon} ${event.title}: ${event.description}',
    );
    _currentTemplateId = event.metadata['templateId'] as String?;
    _currentAnswer = null;
    _currentPlayerIndex = -1;
    notifyListeners();
  }

  /// Verifica si debe terminar un evento en esta ronda
  Future<void> _checkForEventEnding() async {
    final activeEvents = _events
        .where((e) => e.isActiveAtRound(_currentRound))
        .toList();

    for (final event in activeEvents) {
      if (EventGenerator.shouldEndEvent(event, _currentRound)) {
        final eventEnd = EventGenerator.generateEventEnd(event, _currentRound);

        _events = _events.map((e) {
          if (e.id == event.id) {
            return e.copyWith(
              status: EventStatus.ended,
              endRound: _currentRound,
            );
          }
          return e;
        }).toList();

        _currentEventEnd = eventEnd;
        _currentChallenge = eventEnd.endDescription;
        _currentPlayerIndex = -1;
        notifyListeners();

        return;
      }
    }
  }

  /// Verifica si debe terminar un reto constante en esta ronda
  Future<void> _checkForConstantChallengeEnding() async {
    final activeChallenges = _constantChallenges
        .where((c) => c.isActiveAtRound(_currentRound))
        .toList();

    for (final challenge in activeChallenges) {
      if (ConstantChallengeGenerator.shouldEndConstantChallenge(
        challenge,
        _currentRound,
      )) {
        final challengeEnd = ConstantChallengeGenerator.generateChallengeEnd(
          challenge,
          _currentRound,
        );

        _constantChallenges = _constantChallenges.map((c) {
          if (c.id == challenge.id) {
            return c.copyWith(
              status: ConstantChallengeStatus.ended,
              endRound: _currentRound,
            );
          }
          return c;
        }).toList();

        _currentChallengeEnd = challengeEnd;
        _currentChallenge = challengeEnd.endDescription;
        _currentPlayerIndex = -1;
        notifyListeners();

        return;
      }
    }
  }

  /// Verifica el checkpoint de modo endless (ronda 100)
  Future<bool> checkEndlessModeCheckpoint() async {
    if (_currentRound == 100 && !_isEndlessMode) {
      return true; // Le permite al Screen mostrar el diálogo
    }
    return false;
  }

  /// Activa el modo endless
  void activateEndlessMode() {
    _isEndlessMode = true;
    notifyListeners();
  }

  /// Avanza al siguiente desafío. Retorna true si se mostró un anuncio y el usuario no es premium (para mostrar upsell).
  Future<bool> nextChallenge() async {
    _gameStarted = true;
    _currentRound++;
    _currentChallengeEnd = null;
    _currentEventEnd = null;
    _dualPlayerIndex = null;
    _currentAnswer = null;
    _currentTemplateId = null;
    _isCurrentChallengeConstant = false;
    notifyListeners();

    final isPremiumUser = context.read<PackService>().isPremium;
    final adShown = await _interstitial.onRoundCompleted(isPremium: isPremiumUser);

    // Verificar checkpoint de endless mode
    if (await checkEndlessModeCheckpoint()) {
      return false; // El screen manejará el diálogo
    }

    // Si se mostró un anuncio y no es premium, avisamos al UI para el upsell
    if (adShown && !isPremiumUser) {
      // Nota: No generamos el siguiente reto aún o sí? 
      // El usuario querrá ver el siguiente reto TRAS el upsell.
      // Pero mejor generarlo ya para que esté listo.
    }

    // Verificar fin de evento
    await _checkForEventEnding();
    if (_currentEventEnd != null) return adShown && !isPremiumUser;

    // Verificar fin de reto constante
    await _checkForConstantChallengeEnding();
    if (_currentChallengeEnd != null) return adShown && !isPremiumUser;

    // Generar nuevo evento
    final gameState = createGameState();
    if (gameState.canHaveEvents &&
        EventGenerator.shouldGenerateEvent(
          _currentRound,
          gameState.activeEvents,
        )) {
      await _generateNewEvent();
      return adShown && !isPremiumUser;
    }

    // Generar nuevo reto constante
    if (gameState.canHaveConstantChallenges &&
        ConstantChallengeGenerator.shouldGenerateConstantChallenge(
          _currentRound,
          gameState.activeChallenges,
        )) {
      if (_players.length >= 2 && math.Random().nextDouble() < 0.2) {
        await _generateNewDualConstantChallenge();
      } else {
        await _generateNewConstantChallenge();
      }
      return adShown && !isPremiumUser;
    }

    // Generar nuevo desafío normal
    if (_players.length >= 2 && math.Random().nextDouble() < 0.15) {
      await _generateNewDualChallenge();
    } else {
      await _generateNewChallenge();
    }

    // Seleccionar jugador si es necesario
    final gameState2 = createGameState();
    if (!gameState2.isChallengeForAll &&
        !_isGenericPlayerQuestion() &&
        !gameState2.isDualChallenge) {
      _selectWeightedRandomPlayer();
    } else if (gameState2.isChallengeForAll) {
      _currentPlayerIndex = -1;
      notifyListeners();
    }

    return adShown && !isPremiumUser;
  }

  /// Actualiza la lista de jugadores
  void updatePlayers(List<Player> newPlayers) {
    final oldWeights = Map<int, int>.from(_playerWeights);
    _players = List<Player>.from(newPlayers);
    _playerWeights.clear();
    for (final p in _players) {
      _playerWeights[p.id] = oldWeights[p.id] ?? 0;
    }

    // Re-mapear índices de jugadores actuales
    int? newCurrent;
    int? newDual;

    if (_currentPlayerIndex >= 0) {
      final prevId = _currentPlayerIndex < _players.length
          ? _players[_currentPlayerIndex].id
          : null;
      if (prevId != null) {
        newCurrent = _players.indexWhere((p) => p.id == prevId);
      }
    }

    if (_dualPlayerIndex != null &&
        _dualPlayerIndex! >= 0 &&
        _dualPlayerIndex! < _players.length) {
      final prevId2 = _players[_dualPlayerIndex!].id;
      newDual = _players.indexWhere((p) => p.id == prevId2);
    }

    _currentPlayerIndex =
        (newCurrent != null && newCurrent >= 0) ? newCurrent : -1;
    _dualPlayerIndex = (newDual != null && newDual >= 0) ? newDual : null;

    notifyListeners();
  }

  @override
  void dispose() {
    _interstitial.dispose();
    super.dispose();
  }
}
