/// Validador de preguntas para determinar tipo y propiedades
class GameQueryValidator {
  /// Detecta si es una pregunta condicional "Cualquiera que..."
  static bool isConditionalQuestion(String challenge) {
    if (challenge.isEmpty) return false;
    final lowerChallenge = challenge.toLowerCase();
    return lowerChallenge.startsWith('cualquiera que') ||
        lowerChallenge.startsWith('cualquiera con') ||
        lowerChallenge.contains('bebe 3 tragos por cada vocal');
  }

  /// Detecta si es una pregunta "más probable que"
  static bool isMoreLikelyQuestion(String challenge) {
    if (challenge.isEmpty) return false;
    final lowerChallenge = challenge.toLowerCase();
    return lowerChallenge.contains('más probable') ||
        lowerChallenge.contains('señalen a') ||
        lowerChallenge.contains('apunten a');
  }

  /// Detecta si la pregunta es genérica para un jugador
  static bool isGenericPlayerQuestion(String challenge, String playerName) {
    if (challenge.isEmpty) return false;

    return challenge.contains('$playerName bebe') ||
        challenge.contains('$playerName reparte') ||
        challenge.contains('$playerName responde') ||
        challenge.contains('$playerName confiesa');
  }

  /// Detecta si la pregunta tiene multiplicador (por cada letra/vocal)
  static bool hasLetterMultiplier(String challenge) {
    final lowerChallenge = challenge.toLowerCase();
    return lowerChallenge.contains('por cada') &&
        (lowerChallenge.contains('vocal') || lowerChallenge.contains('letra'));
  }

  /// Detecta si debe contar tragos en una pregunta tipo "Cualquiera que..."
  static bool shouldCountDrinks(String challenge) {
    if (challenge.isEmpty) return false;

    final lowerChallenge = challenge.toLowerCase();

    // Excluir duelos y batallas
    if (lowerChallenge.contains(' y ') &&
        (lowerChallenge.contains('entre') ||
            lowerChallenge.contains('juegan') ||
            lowerChallenge.contains('el que sea más') ||
            (lowerChallenge.contains('quien') &&
                lowerChallenge.contains('primero')))) {
      return false;
    }

    // Excluir retos individuales con condiciones
    if (lowerChallenge.contains('reparte') &&
        (lowerChallenge.contains('si logra') ||
            lowerChallenge.contains('si responde') ||
            lowerChallenge.contains('si todos aplauden') ||
            lowerChallenge.contains('si recuerda') ||
            lowerChallenge.contains('si actúa'))) {
      return false;
    }

    if (lowerChallenge.contains('bebe') &&
        (lowerChallenge.contains('si no puede') ||
            lowerChallenge.contains('si no sabe') ||
            lowerChallenge.contains('si no resuelve'))) {
      return false;
    }

    // Excluir repartos por razones
    if (lowerChallenge.contains('reparte') &&
        lowerChallenge.contains('tragos por')) {
      return false;
    }

    if (!isConditionalQuestion(challenge) &&
        lowerChallenge.contains('bebe') &&
        lowerChallenge.contains('tragos por') &&
        !lowerChallenge.contains('vocal')) {
      return false;
    }

    // Excluir repartos (tanto simples como con "cualquiera que")
    if (lowerChallenge.contains('reparte') && lowerChallenge.contains('tragos')) {
      return false;
    }

    return isConditionalQuestion(challenge) || isMoreLikelyQuestion(challenge);
  }

  /// Detecta si es un trago directo para el jugador actual
  static bool isDirectDrinkForCurrentPlayer(
    String challenge,
    String playerName,
  ) {
    if (challenge.isEmpty) return false;

    final lowerChallenge = challenge.toLowerCase();
    final playerNameLower = playerName.toLowerCase();

    // Debe mencionar al jugador y tener "bebe", sin ser reparto
    if (!lowerChallenge.contains(playerNameLower)) return false;
    if (!lowerChallenge.contains('bebe')) return false;
    if (lowerChallenge.contains('reparte')) return false;

    // Excluir preguntas condicionales o "más probable que"
    if (isConditionalQuestion(challenge) || isMoreLikelyQuestion(challenge)) {
      return false;
    }

    return true;
  }

  /// Extrae la letra/vocal a contar
  static String? extractLetterToCount(String challenge) {
    final match = RegExp(
      r'vocal\s+([aeiouAEIOU])',
      caseSensitive: false,
    ).firstMatch(challenge);
    
    if (match != null) {
      return match.group(1)?.toUpperCase();
    }
    return null;
  }

  /// Extrae cantidad de tragos de la pregunta
  static int extractDrinksFromChallenge(String challenge) {
    if (challenge.isEmpty) return 1;

    final lowerChallenge = challenge.toLowerCase();

    final patterns = [
      RegExp(r'bebe\s+(\d+)\s+trago'),
      RegExp(r'bebe\s+(\d+)'),
      RegExp(r'(\d+)\s+trago'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerChallenge);
      if (match != null && match.groupCount >= 1) {
        final drinks = int.tryParse(match.group(1)!);
        if (drinks != null && drinks > 0) {
          return drinks;
        }
      }
    }

    return 1;
  }

  /// Detecta si hay empate entre jugadores
  static bool hasEmpateBetweenPlayers(List<int> selectedPlayerIds) {
    return selectedPlayerIds.length > 1;
  }
}
