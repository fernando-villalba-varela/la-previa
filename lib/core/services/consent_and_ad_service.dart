import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'language_service.dart';

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

class AdIds {
  static const String _testBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _prodBannerId =
      'ca-app-pub-5219310667296097/7363902192';
  static const String _prodInterstitialId =
      'ca-app-pub-5219310667296097/5993213840';

  static String get bannerId =>
      kDebugMode ? _testBannerId : _prodBannerId;
  static String get interstitialId =>
      kDebugMode ? _testInterstitialId : _prodInterstitialId;
}

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

class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _loaded = false;

  int _roundsSince = 0;
  static const int _adFrequency = 100;

  Future<void> loadAd() async {
    if (!kDebugMode && !ConsentService().canShowAds) return;
    if (_loaded) return;

    await InterstitialAd.load(
      adUnitId: AdIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loaded = true;
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd error: ${err.code}');
          _loaded = false;
        },
      ),
    );
  }

  Future<bool> showIfReady({bool isPremium = false}) async {
    if (isPremium) return false;
    if (!_loaded || _ad == null) {
      loadAd();
      return false;
    }
    
    final completer = Completer<void>();
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _loaded = false;
        loadAd();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _ad = null;
        _loaded = false;
        loadAd();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await _ad!.show();
    await completer.future;
    return true;
  }

  Future<void> showOnEntry() async {
    await showIfReady();
  }

  Future<bool> onRoundCompleted({bool isPremium = false}) async {
    _roundsSince++;
    if (_roundsSince >= _adFrequency) {
      final shown = await showIfReady(isPremium: isPremium);
      if (shown) {
        _roundsSince = 0;
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _ad?.dispose();
  }
}

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
    if (!_required && !kDebugMode) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () =>
          ConsentService().showPrivacyOptionsForm(onDismiss: (_) => _check()),
      icon: const Icon(Icons.privacy_tip_outlined,
          size: 14, color: Colors.white54),
      label: Text(
          Provider.of<LanguageService>(context).translate('privacy_button'),
          style: const TextStyle(fontSize: 12, color: Colors.white54)),
    );
  }
}