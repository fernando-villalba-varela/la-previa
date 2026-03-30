import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final bool _isLoading = false;
  String? _errorMessage;
  bool _isAnimating = false;
  Gradient? _currentGradient;
  String? _animatingButtonText;
  IconData? _animatingIcon;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isAnimating => _isAnimating;
  Gradient? get currentGradient => _currentGradient;
  String? get animatingButtonText => _animatingButtonText;
  IconData? get animatingIcon => _animatingIcon;

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

  void startAnimation(Gradient gradient, String buttonText, IconData icon) {
    _isAnimating = true;
    _currentGradient = gradient;
    _animatingButtonText = buttonText;
    _animatingIcon = icon;
    notifyListeners();
  }

  void resetAnimation() {
    _isAnimating = false;
    _currentGradient = null;
    _animatingButtonText = null;
    _animatingIcon = null;
    notifyListeners();
  }

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}

