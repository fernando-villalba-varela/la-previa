import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'generator_utils.dart';

class QuestionTemplate {
  final String id;
  final String template;
  final Map<String, List<String>> variables;
  final String categoria;

  QuestionTemplate({required this.id, required this.template, required this.variables, required this.categoria});

  factory QuestionTemplate.fromJson(Map<String, dynamic> json) {
    return QuestionTemplate(
      id: json['id'],
      template: json['template'],
      variables: Map<String, List<String>>.from(
        json['variables'].map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
      categoria: json['categoria'],
    );
  }
}

class GeneratedQuestion {
  final String question;
  final String categoria;
  final Map<String, String> usedVariables;
  final String? answer; // Respuesta extraída de paréntesis si existe
  final String? templateId; // <-- ANADIR

  GeneratedQuestion({
    required this.question,
    required this.categoria,
    required this.usedVariables,
    this.answer,
    this.templateId, // <-- ANADIR
  });

  // Getters
  String get getQuestion => question;
  String get getCategoria => categoria;
  Map<String, String> get getUsedVariables => usedVariables;
  String? get getAnswer => answer;

  /// Extrae la respuesta del paréntesis si existe
  static String? extractAnswer(String question) {
    final regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(question);
    return match?.group(1);
  }

  /// Limpia la pregunta removiendo la respuesta entre paréntesis
  static String cleanQuestion(String question) {
    return question.replaceAll(RegExp(r'\s*\(.*?\)\s*$'), '').trim();
  }
}

class QuestionGenerator {
  static final Random _random = Random();
  static List<QuestionTemplate>? _templates;
  static String _currentLanguage = 'es';
  static List<String> _currentPacks = ['classic'];
  // Historial compartido para evitar duplicados
  static GeneratorHistory get _history => GeneratorHistory.shared;

  /// Cargar las plantillas desde múltiples JSONs según los packs activos
  static Future<void> loadTemplates({String language = 'es', List<String> activePackIds = const ['classic']}) async {
    // Si ya están cargadas y el idioma y packs son los mismos, no hacer nada
    bool hasSamePacks = _currentPacks.length == activePackIds.length && _currentPacks.toSet().containsAll(activePackIds);
    if (_templates != null && _currentLanguage == language && hasSamePacks) return;

    // Actualizar estado actual
    _currentLanguage = language;
    _currentPacks = List.from(activePackIds);
    
    // Resetear templates para forzar recarga
    _templates = [];

    for (final packId in activePackIds) {
      try {
        String jsonPath;
        if (packId == 'classic') {
          jsonPath = language == 'es' 
              ? 'assets/questions.json' 
              : 'assets/questions_$language.json';
        } else {
          jsonPath = language == 'es' 
              ? 'assets/questions_$packId.json' 
              : 'assets/questions_${packId}_$language.json';
        }
          
        final String jsonString = await rootBundle.loadString(jsonPath);
        final Map<String, dynamic> jsonData = json.decode(jsonString);

        final packTemplates = (jsonData['templates'] as List)
            .map((template) => QuestionTemplate.fromJson(template))
            .toList();
            
        _templates!.addAll(packTemplates);
      } catch (e) {
        if (kDebugMode) {
          print('Error loading questions for pack $packId ($language): $e');
        }
      }
    }

    if (_templates!.isEmpty) {
      // Fallback a español si falla inglés (opcional, pero seguro)
      if (language != 'es') {
        if (kDebugMode) print('Falling back to Spanish questions');
        await loadTemplates(language: 'es', activePackIds: activePackIds);
      }
    }
  }

  /// Genera el número de tragos con probabilidades ponderadas
  /// 70% = 1 trago, 20% = 2 tragos, 10% = 3 tragos
  static String _generateDrinkAmount({String language = 'es', bool skipWord = false}) {
    final randomValue = _random.nextDouble();
    
    int drinks;
    if (randomValue < 0.5) {
      drinks = 1;
    } else if (randomValue < 0.8) {
      drinks = 2;
    } else {
      drinks = 3;
    }
    
    // Si el template ya contiene la palabra "drinks", solo devolver el número
    if (skipWord) {
      return drinks.toString();
    }
    
    // Formato según el idioma
    if (language == 'es') {
      return '$drinks ${drinks == 1 ? 'trago' : 'tragos'}';
    } else if (language == 'en') {
      return '$drinks ${drinks == 1 ? 'drink' : 'drinks'}';
    } else {
      // Para otros idiomas, devolver solo el número
      return drinks.toString();
    }
  }

  /// Generar una pregunta aleatoria (excluyendo templates con PLAYER)
  static Future<GeneratedQuestion> generateRandomQuestion({
    String language = 'es',
    List<String> activePackIds = const ['classic'],
    int? currentRound,
  }) async {
    await loadTemplates(language: language, activePackIds: activePackIds);

    if (_templates == null || _templates!.isEmpty) {
      return GeneratedQuestion(
        question: 'Error: No se pudieron cargar las preguntas',
        categoria: 'Error',
        usedVariables: {},
      );
    }

    // Filtrar templates que NO contengan la variable PLAYER ni variables duales
    final nonPlayerTemplates = _templates!.where((template) {
      return !template.variables.values.any((values) => values.contains('PLAYER')) &&
          !(template.variables.containsKey('PLAYER1') &&
              template.variables.containsKey('PLAYER2') &&
              template.variables['PLAYER1']!.contains('DUAL_PLAYER1') &&
              template.variables['PLAYER2']!.contains('DUAL_PLAYER2'));
    }).toList();

    if (nonPlayerTemplates.isEmpty) {
      // Si todos los templates requieren PLAYER, usar uno cualquiera
      final template = _templates![_random.nextInt(_templates!.length)];
      if (kDebugMode) {
        print('Generando pregunta de la categoría (fallback): ${template.template}');
      }
      return _generateQuestionFromTemplate(template);
    }

    // Usar historial para evitar duplicados recientes
    int attempts = 0;
    QuestionTemplate template;
    GeneratedQuestion question;
    
    do {
      template = nonPlayerTemplates[_random.nextInt(nonPlayerTemplates.length)];
      question = _generateQuestionFromTemplate(template);
      attempts++;
      
      // Doble comprobación:
      // 1. ¿Salió esta plantilla muy recientemente (últimos 20)?
      // 2. ¿Salió este contenido exacto recientemente (últimos 50)?
      bool isDuplicate = _history.isContentRecent(template.id, question.question, limit: 50);
      bool isTemplateRecent = _history.isTemplateRecent(template.id, limit: 20);
      
      // Si llevamos muchos intentos (pool pequeño o mala suerte), relajamos las condiciones
      if (attempts > 10) isTemplateRecent = false; 
      if (attempts > 25) isDuplicate = false; 

      if (!isDuplicate && !isTemplateRecent) break;
    } while (attempts < 30);

    _history.add(template.id, question.question);

    if (kDebugMode) {
      print('--- RONDA ${currentRound ?? "?"} ---');
      print('PREGUNTA [${template.id}]: ${question.question}');
    }
    return question;
  }

  /// Generar una pregunta aleatoria con un jugador específico
  static Future<GeneratedQuestion> generateRandomQuestionForPlayer(
    String playerName, {
    String language = 'es',
    List<String> activePackIds = const ['classic'],
    int? currentRound,
  }) async {
    await loadTemplates(language: language, activePackIds: activePackIds);

    if (_templates == null || _templates!.isEmpty) {
      return GeneratedQuestion(
        question: 'Error: No se pudieron cargar las preguntas',
        categoria: 'Error',
        usedVariables: {},
      );
    }

    // Filtrar solo templates que contengan la variable PLAYER (no dual)
    final playerTemplates = _templates!.where((template) {
      return template.variables.values.any((values) => values.contains('PLAYER')) &&
          !(template.variables.containsKey('PLAYER1') &&
              template.variables.containsKey('PLAYER2') &&
              template.variables['PLAYER1']!.contains('DUAL_PLAYER1') &&
              template.variables['PLAYER2']!.contains('DUAL_PLAYER2'));
    }).toList();

    if (playerTemplates.isEmpty) {
      // Si no hay templates con PLAYER, usar uno normal
      return generateRandomQuestion(language: language, activePackIds: activePackIds, currentRound: currentRound);
    }

    // Usar historial para evitar duplicados recientes
    int attempts = 0;
    QuestionTemplate template;
    GeneratedQuestion question;

    do {
      template = playerTemplates[_random.nextInt(playerTemplates.length)];
      question = _generateQuestionFromTemplate(template, playerName: playerName);
      attempts++;

      bool isDuplicate = _history.isContentRecent(template.id, question.question, limit: 50);
      bool isTemplateRecent = _history.isTemplateRecent(template.id, limit: 15); // Menos restrictivo para jugador
      
      if (attempts > 10) isTemplateRecent = false;
      if (attempts > 25) isDuplicate = false;

      if (!isDuplicate && !isTemplateRecent) break;
    } while (attempts < 30);

    _history.add(template.id, question.question);
    
    if (kDebugMode) {
      print('--- RONDA ${currentRound ?? "?"} ---');
      print('PREGUNTA JUGADOR [${template.id}]: ${question.question}');
    }
    
    return question;
  }

  /// Generar una pregunta dual aleatoria (para 2 jugadores)
  static Future<GeneratedQuestion> generateRandomDualQuestion(
    String player1Name,
    String player2Name, {
    String language = 'es',
    List<String> activePackIds = const ['classic'],
    int? currentRound,
  }) async {
    await loadTemplates(language: language, activePackIds: activePackIds);

    if (_templates == null || _templates!.isEmpty) {
      return generateRandomQuestion(language: language, activePackIds: activePackIds);
    }

    // Filtrar solo templates duales
    final dualTemplates = _templates!.where((template) {
      return template.variables.containsKey('PLAYER1') &&
          template.variables.containsKey('PLAYER2') &&
          template.variables['PLAYER1']!.contains('DUAL_PLAYER1') &&
          template.variables['PLAYER2']!.contains('DUAL_PLAYER2');
    }).toList();

    if (dualTemplates.isEmpty) {
      // Si no hay templates duales, generar uno normal
      return generateRandomQuestion(language: language, activePackIds: activePackIds);
    }

    // Usar historial para evitar duplicados recientes
    int attempts = 0;
    QuestionTemplate template;
    GeneratedQuestion question;

    do {
      template = dualTemplates[_random.nextInt(dualTemplates.length)];
      question = _generateQuestionFromTemplate(template, playerName: player1Name, dualPlayerName: player2Name);
      attempts++;

      bool isDuplicate = _history.isContentRecent(template.id, question.question, limit: 50);
      bool isTemplateRecent = _history.isTemplateRecent(template.id, limit: 15);
      
      if (attempts > 10) isTemplateRecent = false;
      if (attempts > 25) isDuplicate = false;

      if (!isDuplicate && !isTemplateRecent) break;
    } while (attempts < 30);

    _history.add(template.id, question.question);
    
    if (kDebugMode) {
      print('--- RONDA ${currentRound ?? "?"} ---');
      print('PREGUNTA DUAL [${template.id}]: ${question.question}');
    }
    
    return question;
  }

  /// Generar una pregunta de una categoría específica
  static Future<GeneratedQuestion> generateQuestionByCategory(String categoria, {String? playerName, List<String> activePackIds = const ['classic']}) async {
    await loadTemplates(activePackIds: activePackIds);

    if (_templates == null || _templates!.isEmpty) {
      return generateRandomQuestion(activePackIds: activePackIds);
    }

    final categoryTemplates = _templates!.where((template) => template.categoria == categoria).toList();

    if (categoryTemplates.isEmpty) {
      return generateRandomQuestion(activePackIds: activePackIds);
    }

    final template = categoryTemplates[_random.nextInt(categoryTemplates.length)];
    final question = _generateQuestionFromTemplate(template, playerName: playerName);
    _history.add(template.id, question.question);
    return question;
  }

  /// Obtener todas las categorías disponibles
  static Future<List<String>> getCategories({List<String> activePackIds = const ['classic']}) async {
    await loadTemplates(activePackIds: activePackIds);

    if (_templates == null || _templates!.isEmpty) {
      return [];
    }

    return _templates!.map((template) => template.categoria).toSet().toList()..sort();
  }

  /// Generar pregunta desde una plantilla específica
  static GeneratedQuestion _generateQuestionFromTemplate(
    QuestionTemplate template, {
    String? playerName,
    String? dualPlayerName,
  }) {
    String question = template.template;
    Map<String, String> usedVariables = {};

    // Reemplazar cada variable con un valor aleatorio
    template.variables.forEach((variableName, possibleValues) {
      if ((variableName == 'Y' && (possibleValues.contains('tragos') || possibleValues.contains('drinks'))) ||
          (variableName == 'DRINKS')) {
        // Para Y = tragos/drinks o DRINKS, usar el generador de probabilidades
        // Detectar si el template ya contiene "drinks" después de {Y} o {DRINKS}
        bool templateHasDrinks = question.contains('{$variableName} drinks') || 
                                 question.contains('drinks {$variableName}');
        final drinkAmount = _generateDrinkAmount(
          language: _currentLanguage, 
          skipWord: templateHasDrinks
        );
        question = question.replaceAll('{$variableName}', drinkAmount);
        usedVariables[variableName] = drinkAmount;
      } else if (possibleValues.length == 1 && possibleValues[0] == 'PLAYER' && playerName != null) {
        // Para variables que solo contienen PLAYER, usar el nombre del jugador
        question = question.replaceAll('{$variableName}', playerName);
        usedVariables[variableName] = playerName;
      } else if (possibleValues.length == 1 && possibleValues[0] == 'DUAL_PLAYER1' && playerName != null) {
        // Para DUAL_PLAYER1, usar el primer jugador
        question = question.replaceAll('{$variableName}', playerName);
        usedVariables[variableName] = playerName;
      } else if (possibleValues.length == 1 && possibleValues[0] == 'DUAL_PLAYER2' && dualPlayerName != null) {
        // Para DUAL_PLAYER2, usar el segundo jugador
        question = question.replaceAll('{$variableName}', dualPlayerName);
        usedVariables[variableName] = dualPlayerName;
      } else {
        // Para otras variables, selección aleatoria normal
        final selectedValue = possibleValues[_random.nextInt(possibleValues.length)];
        question = question.replaceAll('{$variableName}', selectedValue);
        usedVariables[variableName] = selectedValue;
      }
    });

    // Extraer respuesta si existe
    final answer = GeneratedQuestion.extractAnswer(question);
    // Limpiar la pregunta removiendo la respuesta
    final cleanedQuestion = GeneratedQuestion.cleanQuestion(question);

    return GeneratedQuestion(
      question: cleanedQuestion,
      categoria: template.categoria,
      usedVariables: usedVariables,
      answer: answer,
      templateId: template.id,
    );
  }

  /// Generar múltiples preguntas únicas
  static Future<List<GeneratedQuestion>> generateMultipleQuestions(int count, {List<String> activePackIds = const ['classic']}) async {
    List<GeneratedQuestion> questions = [];
    Set<String> usedQuestions = {};

    int attempts = 0;
    while (questions.length < count && attempts < count * 3) {
      final question = await generateRandomQuestion(activePackIds: activePackIds);
      if (!usedQuestions.contains(question.question)) {
        questions.add(question);
        usedQuestions.add(question.question);
      }
      attempts++;
    }

    return questions;
  }

  /// Método para testear las probabilidades de los tragos
  static void testDrinkProbabilities(int testCount) {
    Map<String, int> counts = {'1 trago': 0, '2 tragos': 0, '3 tragos': 0};

    for (int i = 0; i < testCount; i++) {
      final drink = _generateDrinkAmount();
      counts[drink] = (counts[drink] ?? 0) + 1;
    }

    if (kDebugMode) {
      print('Resultados de $testCount pruebas:');
    }
    counts.forEach((drink, count) {
      final percentage = (count / testCount * 100).toStringAsFixed(1);
      if (kDebugMode) {
        print('$drink: $count veces ($percentage%)');
      }
    });
  }
}

