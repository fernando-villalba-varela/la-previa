import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Mantener si Gridient/Color se usan aquí o en constantes, pero idealmente desacoplar.
// En este caso, dejamos Gradient constants aquí por conveniencia de diseño centralizado,
// pero eliminamos la lógica de navegación y contexto.

class HomeViewModel extends ChangeNotifier {
  final bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  static const LinearGradient quickGameGradient =
      LinearGradient(colors: [Color(0xFFFF0055), Color(0xFFFF5588)]);

  static const LinearGradient leagueGradient =
      LinearGradient(colors: [Color(0xFF00FFFF), Color(0xFF00B3FF)]);

  static const LinearGradient elixirsGradient =
      LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFFFB347)]);

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}

