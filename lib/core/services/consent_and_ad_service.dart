import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// =============================================================================
// consent_service.dart
// Ruta: lib/core/services/consent_service.dart
// =============================================================================

class ConsentService {
  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  bool _canShowAds = false;
  bool _mobileAdsInitialized = false;

  bool get canShowAds => _canShowAds;

  Future<void> initialize() async {
    await _requestConsent();
  }

  Future<void> _requestConsent() async {
    final completer = Completer<void>();

    ConsentDebugSettings? debugSettings;
    if (kDebugMode) {
      debugSettings = ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
        testIdentifiers: const [],
      );
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(consentDebugSettings: debugSettings),
      () async {
        await _showFormIfRequired();
        final can = await ConsentInformation.instance.canRequestAds();
        _canShowAds = can;
        if (_canShowAds) await _initMobileAds();
        completer.complete();
      },
      (FormError error) {
        debugPrint('ConsentService error: ${error.message}');
        _canShowAds = true;
        _initMobileAds();
        completer.complete();
      },
    );

    return completer.future;
  }

  Future<void> _showFormIfRequired() async {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired(
      (FormError? error) {
        if (error != null) debugPrint('ConsentForm: ${error.message}');
        completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> _initMobileAds() async {
    if (_mobileAdsInitialized) return;
    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;
  }

  Future<bool> get isPrivacyOptionsRequired async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  Future<void> showPrivacyOptionsForm(
      {Function(FormError?)? onDismiss}) async {
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      onDismiss?.call(error);
    });
  }
}

// =============================================================================
// ad_service.dart
// Ruta: lib/core/services/ad_service.dart
// =============================================================================

// ── IDs ──────────────────────────────────────────────────────────────────────

class AdIds {
  // IDs de prueba — NO CAMBIAR (son los oficiales de Google para testing)
  static const String _testBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // IDs de produccion — REEMPLAZAR con los de tu cuenta AdMob
  static const String _prodBannerId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodInterstitialId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';

  static String get bannerId =>
      kDebugMode ? _testBannerId : _prodBannerId;
  static String get interstitialId =>
      kDebugMode ? _testInterstitialId : _prodInterstitialId;
}

// ── BANNER ────────────────────────────────────────────────────────────────────

/// Widget de banner fijo. Colocar en bottomNavigationBar del Scaffold.
///
/// Uso en LeagueGameScreen y QuickGameScreen:
///   return SafeArea(
///     child: Scaffold(
///       bottomNavigationBar: const BannerAdWidget(), // <-- ANADIR
///       body: ...
///     ),
///   );
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (!ConsentService().canShowAds) return;

    _ad = BannerAd(
      adUnitId: AdIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd error: ${err.code}');
          ad.dispose();
          _ad = null;
        },
      ),
    );
    _ad!.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}

// ── INTERSTITIAL ─────────────────────────────────────────────────────────────

/// Gestor de interstitials con precarga automatica.
///
/// Uso en LeagueGameScreen:
///   final _interstitial = InterstitialAdManager();
///
///   @override void initState() {
///     super.initState();
///     _interstitial.loadAd();  // precargar al inicio
///   }
///
///   @override void dispose() {
///     _interstitial.dispose();
///     super.dispose();
///   }
///
///   // Al terminar la partida (antes de Navigator.pop):
///   await _interstitial.showIfReady();
class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _loaded = false;

  /// Frecuencia: mostrar cada N rondas (modo rapido)
  int _roundsSince = 0;
  static const int _adFrequency = 5;

  Future<void> loadAd() async {
    if (!ConsentService().canShowAds || _loaded) return;

    await InterstitialAd.load(
      adUnitId: AdIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loaded = true;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              _loaded = false;
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _ad = null;
              _loaded = false;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd error: ${err.code}');
          _loaded = false;
        },
      ),
    );
  }

  Future<bool> showIfReady() async {
    if (!_loaded || _ad == null) {
      loadAd();
      return false;
    }
    await _ad!.show();
    return true;
  }

  /// Llamar en cada avance de ronda en QuickGameScreen.
  /// Muestra el interstitial automaticamente cada [_adFrequency] rondas.
  Future<void> onRoundCompleted() async {
    _roundsSince++;
    if (_roundsSince >= _adFrequency) {
      final shown = await showIfReady();
      if (shown) _roundsSince = 0;
    }
  }

  void dispose() {
    _ad?.dispose();
  }
}

// ── BOTON DE PRIVACIDAD (para home o ajustes) ─────────────────────────────────

/// Muestra el boton de privacidad GDPR solo cuando es obligatorio (usuarios EEA).
/// Anadir en HomeScreen o en una pantalla de ajustes.
class PrivacyOptionsButton extends StatefulWidget {
  const PrivacyOptionsButton({super.key});

  @override
  State<PrivacyOptionsButton> createState() =>
      _PrivacyOptionsButtonState();
}

class _PrivacyOptionsButtonState extends State<PrivacyOptionsButton> {
  bool _required = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final req = await ConsentService().isPrivacyOptionsRequired;
    if (mounted) setState(() => _required = req);
  }

  @override
  Widget build(BuildContext context) {
    if (!_required) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () =>
          ConsentService().showPrivacyOptionsForm(onDismiss: (_) => _check()),
      icon: const Icon(Icons.privacy_tip_outlined,
          size: 14, color: Colors.white54),
      label: const Text('Privacidad',
          style: TextStyle(fontSize: 12, color: Colors.white54)),
    );
  }
}
