import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centraliza todos los eventos de Firebase Analytics de la app.
/// Usar como singleton: AnalyticsService().logXxx(...)
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ─── PAYWALL ──────────────────────────────────────────────────────────────

  /// Usuario ve la pantalla premium. [source]: 'quick_game' | 'league' | 'home'
  Future<void> logPaywallViewed({required String source}) =>
      _log('paywall_viewed', {'source': source});

  /// Usuario completa la compra premium.
  Future<void> logPremiumPurchased() =>
      _log('premium_purchased', {});

  /// Usuario cierra el paywall sin comprar.
  Future<void> logPaywallSkipped({required String source}) =>
      _log('paywall_skipped', {'source': source});

  // ─── PARTIDAS ─────────────────────────────────────────────────────────────

  /// Usuario inicia una partida.
  /// [mode]: 'quick' | 'league'
  /// [packs]: packs activos separados por coma, ej: 'classic,bar'
  /// [isPremium]: si el usuario es premium
  Future<void> logGameStarted({
    required String mode,
    required String packs,
    required bool isPremium,
  }) =>
      _log('game_started', {
        'mode': mode,
        'packs': packs,
        'is_premium': isPremium ? '1' : '0',
      });

  /// Usuario termina una partida (llega a resultados).
  /// [mode]: 'quick' | 'league'
  /// [roundsPlayed]: rondas jugadas
  Future<void> logGameCompleted({
    required String mode,
    required int roundsPlayed,
  }) =>
      _log('game_completed', {
        'mode': mode,
        'rounds_played': roundsPlayed,
      });

  // ─── LIGAS ────────────────────────────────────────────────────────────────

  /// Usuario crea una nueva liga.
  Future<void> logLeagueCreated() =>
      _log('league_created', {});

  // ─── INTERNO ──────────────────────────────────────────────────────────────

  Future<void> _log(String name, Map<String, Object> params) async {
    try {
      await _analytics.logEvent(name: name, parameters: params.isEmpty ? null : params);
    } catch (e) {
      if (kDebugMode) print('[Analytics] Error logging $name: $e');
    }
  }
}
