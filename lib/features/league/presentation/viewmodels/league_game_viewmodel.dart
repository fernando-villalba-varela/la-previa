import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:math' as math show Random;
import '../../../../core/models/player.dart';
import '../../../../core/models/game_state.dart';
import '../../../../core/models/constant_challenge.dart';
import '../../../../core/models/constant_challenge_generator.dart';
import '../../../../core/models/event.dart';
import '../../../../core/models/event_generator.dart';
import '../../../../core/models/question_generator.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/database_service_v2.dart';
import 'game_query_validator.dart';

class LeagueGameViewModel extends ChangeNotifier {
  // Estado del juego
  int _currentPlayerIndex = -1;
  int? _dualPlayerIndex;
  String _currentChallenge = '';
  String? _currentAnswer;
  String? _currentTemplateId;
  bool _gameStarted = false;
  int _currentRound = 1;
  bool _isCurrentChallengeConstant = false;
  bool _showingPlayerSelector = false;
  bool _showingLetterCounter = false;
  List<int> _selectedPlayerIdsForLetterCounter = [];

  // Datos
  final List<Player> players;
  final Map<int, int> playerWeights = {};
  final Map<int, int> playerDrinks = {};
  final List<ConstantChallenge> constantChallenges = [];
  ConstantChallengeEnd? currentChallengeEnd;
  final List<Event> events = [];
  EventEnd? currentEventEnd;
  final Set<String> _usedQuestions = <String>{};
  // Cola sin repetición para preguntas personalizadas
  final List<CustomQuestion> _pendingCustomQuestions = [];
  int _maxRounds = 40; // se actualiza en nextChallenge

  // Getters
  int get currentPlayerIndex => _currentPlayerIndex;
  int? get dualPlayerIndex => _dualPlayerIndex;
  String get currentChallenge => _currentChallenge;
  String? get currentAnswer => _currentAnswer;
  String? get currentTemplateId => _currentTemplateId;
  bool get gameStarted => _gameStarted;
  int get currentRound => _currentRound;
  bool get isCurrentChallengeConstant => _isCurrentChallengeConstant;
  bool get showingPlayerSelector => _showingPlayerSelector;
  bool get showingLetterCounter => _showingLetterCounter;
  List<int> get selectedPlayerIdsForLetterCounter => _selectedPlayerIdsForLetterCounter;
  Map<int, int> get finalDrinks => playerDrinks;

  LeagueGameViewModel({required this.players}) {
    _initializePlayerData();
  }

  void _initializePlayerData() {
    for (int i = 0; i < players.length; i++) {
      playerWeights[i] = 0;
      playerDrinks[players[i].id] = 0;
    }
  }

  // -------------------------------------------------------------------------
  // Loading / Initialization
  // -------------------------------------------------------------------------

  Future<void> loadCustomQuestions(DatabaseService db, String leagueId) async {
    final qs = await db.getActivePersonalizedQuestions(leagueId);
    // Cola barajada: cada pregunta aparece una sola vez por partida
    _pendingCustomQuestions
      ..clear()
      ..addAll(qs)
      ..shuffle(Random());
  }

  Future<void> initializeFirstChallenge(LanguageService lang, List<String> activePackIds) async {
    await _generateNewChallenge(lang, activePackIds);

    final gs = _buildGameState(AlwaysStoppedAnimation<double>(0.0));
    if (!gs.isChallengeForAll && !isGenericPlayerQuestion() && !gs.isDualChallenge) {
      _selectWeightedRandomPlayer();
    } else if (gs.isChallengeForAll) {
      _currentPlayerIndex = -1;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------------
  // Challenge generation (private)
  // -------------------------------------------------------------------------

  Future<void> _generateNewChallenge(LanguageService lang, List<String> activePackIds) async {
    if (_pendingCustomQuestions.isNotEmpty) {
      // Probabilidad dinámica: distribuir las preguntas pendientes entre las
      // rondas restantes (~70% de las rondas generan un reto normal).
      final remaining = (_maxRounds - _currentRound).clamp(1, _maxRounds);
      final estimatedRemainingChallenges = (remaining * 0.7).ceil().clamp(1, 999);
      final prob = (_pendingCustomQuestions.length / estimatedRemainingChallenges)
          .clamp(0.0, 0.5);

      if (Random().nextDouble() < prob) {
        final CustomQuestion cq = _pendingCustomQuestions.removeAt(0);
        final drinkText = cq.drinks == 1
            ? lang.translate('drink_singular')
            : lang.translate('drink_plural');

        _currentChallenge = '${cq.text}\n\n[🍻 ${cq.drinks} $drinkText]';
        _currentAnswer = null;
        _currentTemplateId = cq.id;
        _currentPlayerIndex = -1;
        notifyListeners();
        return;
      }
    }

    if (Random().nextDouble() < 0.3 && players.isNotEmpty) {
      final selectedPlayerIndex = Random().nextInt(players.length);
      final selectedPlayer = players[selectedPlayerIndex];

      var attempts = 0;
      GeneratedQuestion question;
      do {
        question = await QuestionGenerator.generateRandomQuestionForPlayer(selectedPlayer.nombre, activePackIds: activePackIds);
        attempts++;
      } while (_usedQuestions.contains(question.question) && attempts < 30);
      _usedQuestions.add(question.question);

      _currentChallenge = question.question;
      _currentAnswer = question.answer;
      _currentTemplateId = question.templateId;
      _currentPlayerIndex = selectedPlayerIndex;
      notifyListeners();
    } else {
      var attempts = 0;
      GeneratedQuestion question;
      do {
        question = await QuestionGenerator.generateRandomQuestion(activePackIds: activePackIds);
        attempts++;
      } while (_usedQuestions.contains(question.question) && attempts < 30);
      _usedQuestions.add(question.question);

      _currentChallenge = question.question;
      _currentAnswer = question.answer;
      _currentTemplateId = question.templateId;
      _currentPlayerIndex = -1;
      notifyListeners();
    }
  }

  Future<void> _generateNewEvent(List<String> activePackIds) async {
    final event = await EventGenerator.generateRandomEvent(_currentRound, activePackIds: activePackIds);

    events.add(event);
    _currentChallenge = '${event.typeIcon} ${event.title}: ${event.description}';
    _currentTemplateId = event.metadata['templateId'] as String?;
    _currentAnswer = null;
    _currentPlayerIndex = -1;
    notifyListeners();
  }

  Future<void> _generateNewConstantChallenge(List<String> activePackIds) async {
    final eligiblePlayer = ConstantChallengeGenerator.selectPlayerForNewChallenge(
      players,
      constantChallenges.where((c) => c.isActiveAtRound(_currentRound)).toList(),
    );

    if (eligiblePlayer == null) {
      // Fall back to normal challenge – lang not available here so skip
      return;
    }

    final constantChallenge = await ConstantChallengeGenerator.generateRandomConstantChallenge(
      eligiblePlayer,
      _currentRound,
      activePackIds: activePackIds,
    );

    constantChallenges.add(constantChallenge);
    _currentChallenge = constantChallenge.description;
    _currentTemplateId = constantChallenge.metadata['templateId'] as String?;
    _currentAnswer = null;
    _currentPlayerIndex = players.indexWhere((p) => p.id == eligiblePlayer.id);
    _isCurrentChallengeConstant = true;
    notifyListeners();
  }

  Future<void> _generateNewDualChallenge(LanguageService lang, List<String> activePackIds) async {
    final selectedPlayers = _selectTwoRandomPlayers();
    if (selectedPlayers.length < 2) {
      await _generateNewChallenge(lang, activePackIds);
      return;
    }

    final player1 = selectedPlayers[0];
    final player2 = selectedPlayers[1];

    var attempts = 0;
    GeneratedQuestion question;
    do {
      question = await QuestionGenerator.generateRandomDualQuestion(player1.nombre, player2.nombre, activePackIds: activePackIds);
      attempts++;
    } while (_usedQuestions.contains(question.question) && attempts < 30);
    _usedQuestions.add(question.question);

    final player1Index = players.indexOf(player1);
    final player2Index = players.indexOf(player2);

    _currentChallenge = question.question;
    _currentAnswer = question.answer;
    _currentTemplateId = question.templateId;
    _currentPlayerIndex = player1Index;
    _dualPlayerIndex = player2Index;

    playerWeights[_currentPlayerIndex] = (playerWeights[_currentPlayerIndex] ?? 0) + 1;
    playerWeights[_dualPlayerIndex!] = (playerWeights[_dualPlayerIndex!] ?? 0) + 1;
    notifyListeners();
  }

  Future<void> _generateNewDualConstantChallenge(List<String> activePackIds) async {
    final selectedPlayers = _selectTwoRandomPlayers();
    if (selectedPlayers.length < 2) {
      await _generateNewConstantChallenge(activePackIds);
      return;
    }

    final player1 = selectedPlayers[0];
    final player2 = selectedPlayers[1];

    final constantChallenge = await ConstantChallengeGenerator.generateRandomDualConstantChallenge(
      player1,
      player2,
      _currentRound,
      activePackIds: activePackIds,
    );

    constantChallenges.add(constantChallenge);
    _currentChallenge = constantChallenge.description;
    _currentTemplateId = constantChallenge.metadata['templateId'] as String?;
    _currentPlayerIndex = players.indexOf(player1);
    _dualPlayerIndex = players.indexOf(player2);
    notifyListeners();
  }

  Future<void> _checkForEventEnding() async {
    final activeEvents = events.where((e) => e.isActiveAtRound(_currentRound)).toList();

    for (final event in activeEvents) {
      if (EventGenerator.shouldEndEvent(event, _currentRound)) {
        final eventEnd = EventGenerator.generateEventEnd(event, _currentRound);

        for (int i = 0; i < events.length; i++) {
          if (events[i].id == event.id) {
            events[i] = events[i].copyWith(status: EventStatus.ended, endRound: _currentRound);
          }
        }

        currentEventEnd = eventEnd;
        _currentChallenge = eventEnd.endDescription;
        _currentPlayerIndex = -1;
        notifyListeners();
        return;
      }
    }
  }

  Future<void> _checkForConstantChallengeEnding() async {
    final activeChallenges =
        constantChallenges.where((c) => c.isActiveAtRound(_currentRound)).toList();

    for (final challenge in activeChallenges) {
      if (ConstantChallengeGenerator.shouldEndConstantChallenge(challenge, _currentRound)) {
        final challengeEnd =
            ConstantChallengeGenerator.generateChallengeEnd(challenge, _currentRound);

        for (int i = 0; i < constantChallenges.length; i++) {
          if (constantChallenges[i].id == challenge.id) {
            constantChallenges[i] = constantChallenges[i]
                .copyWith(status: ConstantChallengeStatus.ended, endRound: _currentRound);
          }
        }

        currentChallengeEnd = challengeEnd;
        _currentChallenge = challengeEnd.endDescription;
        _currentPlayerIndex = -1;
        notifyListeners();
        return;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Public game flow
  // -------------------------------------------------------------------------

  /// Returns true if game ended (round > maxRounds).
  Future<bool> nextChallenge(LanguageService lang, List<String> activePackIds, int maxRounds) async {
    _maxRounds = maxRounds;
    _gameStarted = true;
    _currentRound++;
    currentChallengeEnd = null;
    currentEventEnd = null;
    _dualPlayerIndex = null;
    _currentAnswer = null;
    _isCurrentChallengeConstant = false;
    notifyListeners();

    if (_currentRound > maxRounds) {
      return true;
    }

    final tempGs = _buildGameState(AlwaysStoppedAnimation<double>(0.0));

    await _checkForEventEnding();
    if (currentEventEnd != null) return false;

    await _checkForConstantChallengeEnding();
    if (currentChallengeEnd != null) return false;

    if (tempGs.canHaveEvents &&
        EventGenerator.shouldGenerateEvent(_currentRound, tempGs.activeEvents)) {
      await _generateNewEvent(activePackIds);
      return false;
    }

    if (tempGs.canHaveConstantChallenges &&
        ConstantChallengeGenerator.shouldGenerateConstantChallenge(
            _currentRound, tempGs.activeChallenges)) {
      if (players.length >= 2 && math.Random().nextDouble() < 0.2) {
        await _generateNewDualConstantChallenge(activePackIds);
      } else {
        await _generateNewConstantChallenge(activePackIds);
        // If constant challenge returned without setting one, fall through to normal
        if (!_isCurrentChallengeConstant) {
          await _generateNewChallenge(lang, activePackIds);
        }
      }
      final gs2 = _buildGameState(AlwaysStoppedAnimation<double>(0.0));
      if (!gs2.isChallengeForAll && !isGenericPlayerQuestion() && !gs2.isDualChallenge) {
        _selectWeightedRandomPlayer();
      } else if (gs2.isChallengeForAll) {
        _currentPlayerIndex = -1;
        notifyListeners();
      }
      return false;
    }

    if (players.length >= 2 && math.Random().nextDouble() < 0.15) {
      await _generateNewDualChallenge(lang, activePackIds);
    } else {
      await _generateNewChallenge(lang, activePackIds);
    }

    final gs3 = _buildGameState(AlwaysStoppedAnimation<double>(0.0));
    if (!gs3.isChallengeForAll && !isGenericPlayerQuestion() && !gs3.isDualChallenge) {
      _selectWeightedRandomPlayer();
    } else if (gs3.isChallengeForAll) {
      _currentPlayerIndex = -1;
      notifyListeners();
    }

    return false;
  }

  // -------------------------------------------------------------------------
  // Player selection
  // -------------------------------------------------------------------------

  void _selectWeightedRandomPlayer() {
    if (playerWeights.isEmpty) return;
    int minWeight = playerWeights.values.reduce((a, b) => a < b ? a : b);

    List<int> eligiblePlayers = [];
    playerWeights.forEach((playerIndex, weight) {
      if (weight == minWeight) {
        eligiblePlayers.add(playerIndex);
      }
    });

    if (eligiblePlayers.length < players.length ~/ 2) {
      playerWeights.forEach((playerIndex, weight) {
        if (weight == minWeight + 1 && !eligiblePlayers.contains(playerIndex)) {
          eligiblePlayers.add(playerIndex);
        }
      });
    }

    int selectedPlayer = eligiblePlayers[math.Random().nextInt(eligiblePlayers.length)];

    _currentPlayerIndex = selectedPlayer;
    playerWeights[selectedPlayer] = (playerWeights[selectedPlayer] ?? 0) + 1;
    notifyListeners();
  }

  List<Player> _selectTwoRandomPlayers() {
    if (players.length < 2) return [];

    List<Player> eligiblePlayers = [];
    int minWeight = playerWeights.values.isEmpty
        ? 0
        : playerWeights.values.reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < players.length; i++) {
      int weight = playerWeights[i] ?? 0;
      if (weight <= minWeight + 1) {
        eligiblePlayers.add(players[i]);
      }
    }

    if (eligiblePlayers.length < 2) {
      eligiblePlayers = List.from(players);
    }

    eligiblePlayers.shuffle(math.Random());
    return eligiblePlayers.take(2).toList();
  }

  // -------------------------------------------------------------------------
  // Query delegation
  // -------------------------------------------------------------------------

  bool isConditionalQuestion() {
    return GameQueryValidator.isConditionalQuestion(_currentChallenge);
  }

  bool isMoreLikelyQuestion() {
    return GameQueryValidator.isMoreLikelyQuestion(_currentChallenge);
  }

  bool isGenericPlayerQuestion() {
    if (_currentPlayerIndex < 0 || _currentPlayerIndex >= players.length) return false;
    return GameQueryValidator.isGenericPlayerQuestion(
      _currentChallenge,
      players[_currentPlayerIndex].nombre,
    );
  }

  bool hasLetterMultiplier() {
    return GameQueryValidator.hasLetterMultiplier(_currentChallenge);
  }

  bool shouldCountDrinks() {
    return GameQueryValidator.shouldCountDrinks(_currentChallenge);
  }

  String? extractLetterToCount() {
    return GameQueryValidator.extractLetterToCount(_currentChallenge);
  }

  int extractDrinks() {
    return GameQueryValidator.extractDrinksFromChallenge(_currentChallenge);
  }

  bool isDirectDrinkForCurrentPlayer() {
    if (_currentChallenge.isEmpty) return false;
    if (_currentPlayerIndex < 0 || _currentPlayerIndex >= players.length) return false;
    if (isConditionalQuestion() || isMoreLikelyQuestion()) return false;
    if (_dualPlayerIndex != null) return false;

    final lowerChallenge = _currentChallenge.toLowerCase();
    final playerName = players[_currentPlayerIndex].nombre.toLowerCase();

    if (!lowerChallenge.contains(playerName)) return false;
    if (!lowerChallenge.contains('bebe')) return false;
    if (lowerChallenge.contains('reparte')) return false;

    return true;
  }

  // -------------------------------------------------------------------------
  // Drink application
  // -------------------------------------------------------------------------

  void applyDirectDrinksForCurrentPlayer() {
    if (!isDirectDrinkForCurrentPlayer()) return;

    final playerId = players[_currentPlayerIndex].id;
    final drinksAmount = extractDrinks();

    playerDrinks[playerId] = (playerDrinks[playerId] ?? 0) + drinksAmount;
    notifyListeners();
  }

  void applyMoreLikelyQuestionDrinks(List<int> selectedPlayerIds) {
    if (shouldCountDrinks()) {
      final drinksAmount = extractDrinks();
      for (final playerId in selectedPlayerIds) {
        playerDrinks[playerId] = (playerDrinks[playerId] ?? 0) + drinksAmount;
      }
    }
    _showingPlayerSelector = false;
    notifyListeners();
  }

  void applyLetterCounterDrinks(Map<int, int> drinksByPlayer) {
    drinksByPlayer.forEach((playerId, drinks) {
      playerDrinks[playerId] = (playerDrinks[playerId] ?? 0) + drinks;
    });
    _showingLetterCounter = false;
    _selectedPlayerIdsForLetterCounter = [];
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // UI state setters
  // -------------------------------------------------------------------------

  void setShowingPlayerSelector(bool value) {
    _showingPlayerSelector = value;
    notifyListeners();
  }

  void setLetterCounter(bool show, List<int> selectedIds) {
    _showingLetterCounter = show;
    _selectedPlayerIdsForLetterCounter = selectedIds;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // GameState factory
  // -------------------------------------------------------------------------

  GameState createGameState(Animation<double> glowAnimation) {
    return _buildGameState(glowAnimation);
  }

  GameState _buildGameState(Animation<double> glowAnimation) {
    String? dualPlayer1Name;
    String? dualPlayer2Name;

    if (_dualPlayerIndex != null && _currentPlayerIndex >= 0) {
      if (_currentPlayerIndex < players.length) {
        dualPlayer1Name = players[_currentPlayerIndex].nombre;
      }
      if (_dualPlayerIndex! < players.length) {
        dualPlayer2Name = players[_dualPlayerIndex!].nombre;
      }
    }

    return GameState(
      players: players,
      currentPlayerIndex: _currentPlayerIndex,
      currentChallenge: _currentChallenge,
      currentAnswer: _currentAnswer,
      glowAnimation: glowAnimation,
      playerWeights: playerWeights,
      gameStarted: _gameStarted,
      currentGift: null,
      currentRound: _currentRound,
      constantChallenges: List.unmodifiable(constantChallenges),
      currentChallengeEnd: currentChallengeEnd,
      events: List.unmodifiable(events),
      currentEventEnd: currentEventEnd,
      dualPlayerIndex: _dualPlayerIndex,
      dualPlayer1Name: dualPlayer1Name,
      dualPlayer2Name: dualPlayer2Name,
      isCurrentChallengeConstant: _isCurrentChallengeConstant,
      currentTemplateId: _currentTemplateId,
    );
  }
}
