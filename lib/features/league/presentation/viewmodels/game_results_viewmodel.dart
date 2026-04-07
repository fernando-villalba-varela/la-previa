import 'package:flutter/material.dart';
import '../../../../core/models/player.dart';

class GameResultsViewModel extends ChangeNotifier {
  Player? _resolvedMVP;
  Player? _resolvedRatita;
  bool _mvpTieResolved = false;
  bool _ratitaTieResolved = false;

  Player? get resolvedMVP => _resolvedMVP;
  Player? get resolvedRatita => _resolvedRatita;
  bool get mvpTieResolved => _mvpTieResolved;
  bool get ratitaTieResolved => _ratitaTieResolved;

  void setResolvedMVP(Player player) {
    _resolvedMVP = player;
    _mvpTieResolved = true;
    notifyListeners();
  }

  void setResolvedRatita(Player player) {
    _resolvedRatita = player;
    _ratitaTieResolved = true;
    notifyListeners();
  }

  void reset() {
    _resolvedMVP = null;
    _resolvedRatita = null;
    _mvpTieResolved = false;
    _ratitaTieResolved = false;
    notifyListeners();
  }

  /// Obtiene el jugador MVP (más tragos) de la lista de jugadores
  Player? getMVPPlayer(
    List<Player> players,
    Map<int, int> playerDrinks,
  ) {
    if (_mvpTieResolved && _resolvedMVP != null) {
      return _resolvedMVP;
    }

    if (playerDrinks.isEmpty) return null;

    int maxDrinks =
        playerDrinks.values.reduce((a, b) => a > b ? a : b);
    return players.firstWhere(
      (p) => playerDrinks[p.id] == maxDrinks,
      orElse: () => players.first,
    );
  }

  /// Obtiene el jugador Ratita (menos tragos) de la lista de jugadores
  /// Descarta al MVP resuelto si aplica
  Player? getRatitaPlayer(
    List<Player> players,
    Map<int, int> playerDrinks,
  ) {
    if (_ratitaTieResolved && _resolvedRatita != null) {
      return _resolvedRatita;
    }

    if (playerDrinks.isEmpty) return null;

    int minDrinks = playerDrinks.values.reduce((a, b) => a < b ? a : b);

    // Obtener el MVP resuelto (manual o automático) para excluirlo siempre
    final mvp = getMVPPlayer(players, playerDrinks);

    List<Player> ratitaCandidates = players.where((p) {
      bool hasMinDrinks = playerDrinks[p.id] == minDrinks;
      bool isNotMVP = mvp == null || p.id != mvp.id;
      return hasMinDrinks && isNotMVP;
    }).toList();

    return ratitaCandidates.isNotEmpty
        ? ratitaCandidates.first
        : players.firstWhere(
            (p) => playerDrinks[p.id] == minDrinks && (mvp == null || p.id != mvp.id),
            orElse: () => players.first,
          );
  }

  /// Determina si hay empate en MVP
  bool hasMVPTie(List<Player> players, Map<int, int> playerDrinks) {
    if (_mvpTieResolved || playerDrinks.isEmpty) return false;

    int maxDrinks =
        playerDrinks.values.reduce((a, b) => a > b ? a : b);
    List<int> mvpPlayerIds = playerDrinks.entries
        .where((entry) => entry.value == maxDrinks)
        .map((entry) => entry.key)
        .toList();

    return mvpPlayerIds.length > 1;
  }

  /// Determina si hay empate en Ratita
  bool hasRatitaTie(List<Player> players, Map<int, int> playerDrinks) {
    if (_ratitaTieResolved || playerDrinks.isEmpty) return false;

    int minDrinks =
        playerDrinks.values.reduce((a, b) => a < b ? a : b);
    List<int> ratitaPlayerIds = playerDrinks.entries
        .where((entry) => entry.value == minDrinks)
        .map((entry) => entry.key)
        .toList();

    // EXCLUIR al MVP resuelto de la lista de candidatos a Ratita
    if (_mvpTieResolved && _resolvedMVP != null) {
      ratitaPlayerIds.removeWhere((id) => id == _resolvedMVP!.id);
    }

    return ratitaPlayerIds.length > 1;
  }

  /// Obtiene los jugadores que están en desempate para MVP
  List<Player> getMVPTiedPlayers(
    List<Player> players,
    Map<int, int> playerDrinks,
  ) {
    int maxDrinks =
        playerDrinks.values.reduce((a, b) => a > b ? a : b);
    List<int> mvpPlayerIds = playerDrinks.entries
        .where((entry) => entry.value == maxDrinks)
        .map((entry) => entry.key)
        .toList();

    return players.where((p) => mvpPlayerIds.contains(p.id)).toList();
  }

  /// Obtiene los jugadores que están en desempate para Ratita
  List<Player> getRatitaTiedPlayers(
    List<Player> players,
    Map<int, int> playerDrinks,
  ) {
    int minDrinks =
        playerDrinks.values.reduce((a, b) => a < b ? a : b);
    List<int> ratitaPlayerIds = playerDrinks.entries
        .where((entry) => entry.value == minDrinks)
        .map((entry) => entry.key)
        .toList();

    // EXCLUIR al MVP resuelto
    if (_mvpTieResolved && _resolvedMVP != null) {
      ratitaPlayerIds.removeWhere((id) => id == _resolvedMVP!.id);
    }

    return players.where((p) => ratitaPlayerIds.contains(p.id)).toList();
  }

  /// Obtiene la puntuación máxima (para MVP)
  int getMaxDrinks(Map<int, int> playerDrinks) {
    if (playerDrinks.isEmpty) return 0;
    return playerDrinks.values.reduce((a, b) => a > b ? a : b);
  }

  /// Obtiene la puntuación mínima (para Ratita)
  int getMinDrinks(Map<int, int> playerDrinks) {
    if (playerDrinks.isEmpty) return 0;
    return playerDrinks.values.reduce((a, b) => a < b ? a : b);
  }

  /// Determina si debe mostrar confeti (no hay desempates)
  bool shouldShowConfetti(
    List<Player> players,
    Map<int, int> playerDrinks,
  ) {
    return !hasMVPTie(players, playerDrinks) && !hasRatitaTie(players, playerDrinks);
  }
}
