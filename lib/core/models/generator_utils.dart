import 'dart:collection';

/// Clase que gestiona el historial de plantillas recientes para evitar duplicados.
class GeneratorHistory {
  final int maxHistory;
  final ListQueue<String> _history = ListQueue<String>();
  final ListQueue<String> _templateHistory = ListQueue<String>();

  // Singleton instance to be shared across all generators
  static final GeneratorHistory shared = GeneratorHistory(maxHistory: 100);

  GeneratorHistory({this.maxHistory = 50});

  /// Normaliza el texto para la comparación (ignora números y minúsculas).
  String _normalize(String text) {
    String normalized = text.toLowerCase();
    
    // Reemplazar números por '#'
    normalized = normalized.replaceAll(RegExp(r'\d+'), '#');
    
    // Eliminar espacios y puntuación común para que "panda de payasos!" sea igual a "panda de payasos"
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), '');
    normalized = normalized.trim();
    
    return normalized;
  }

  /// Comprueba si un texto generado es reciente (últimos N turnos).
  bool isContentRecent(String id, String text, {int limit = 50}) {
    final signature = '$id|${_normalize(text)}';
    // Mirar solo los últimos 'limit' elementos del historial
    final relevantHistory = _history.toList().reversed.take(limit);
    return relevantHistory.contains(signature);
  }

  /// Comprueba si un ID de plantilla es reciente (últimos N turnos).
  bool isTemplateRecent(String id, {int limit = 20}) {
    final relevantHistory = _templateHistory.toList().reversed.take(limit);
    return relevantHistory.contains(id);
  }

  /// Añade una generación al historial.
  void add(String id, String text) {
    final signature = '$id|${_normalize(text)}';
    
    _history.addLast(signature);
    _templateHistory.addLast(id);
    
    if (_history.length > maxHistory) _history.removeFirst();
    if (_templateHistory.length > maxHistory) _templateHistory.removeFirst();
  }

  /// Limpia el historial.
  void clear() {
    _history.clear();
    _templateHistory.clear();
  }

  int get length => _history.length;
}
