import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/pack_service.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../../../../core/presentation/components/neon_header.dart';

class PremiumOfferScreen extends StatefulWidget {
  final Route nextRoute;
  final bool isModal;
  final String source;

  const PremiumOfferScreen({
    super.key,
    required this.nextRoute,
    this.isModal = false,
    this.source = 'unknown',
  });

  @override
  State<PremiumOfferScreen> createState() => _PremiumOfferScreenState();
}

class _PremiumOfferScreenState extends State<PremiumOfferScreen> {
  int _tapCount = 0;
  bool _showDevField = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsService().logPaywallViewed(source: widget.source);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onIconTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      setState(() => _showDevField = true);
    }
  }

  Future<void> _redeemCode() async {
    final success = await context.read<PackService>().redeemDevCode(_codeController.text);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código válido. ¡Todo desbloqueado!'), backgroundColor: Colors.green),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (widget.isModal) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(context, widget.nextRoute);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código incorrecto'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      body: NeonBackgroundLayer(
        child: SafeArea(
          child: Column(
            children: [
              NeonHeader(
                title: context.read<LanguageService>().translate('premium_title'),
                subtitle: context.read<LanguageService>().translate('premium_subtitle'),
                themeColor: const Color(0xFFFF0055),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      GestureDetector(
                        onTap: _onIconTap,
                        child: const Icon(Icons.star, color: Color(0xFFFF0055), size: 100),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        context.read<LanguageService>().translate('premium_headline'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.read<LanguageService>().translate('premium_description'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      if (_showDevField) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Código de desarrollador',
                                  hintStyle: const TextStyle(color: Colors.white38),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _redeemCode,
                              icon: const Icon(Icons.check_circle, color: Color(0xFFFF0055), size: 32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildBuyButton(context),
                      const SizedBox(height: 20),
                      if (widget.source == 'league_gate')
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Volver',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            AnalyticsService().logPaywallSkipped(source: widget.source);
                            if (widget.isModal) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(context, widget.nextRoute);
                            }
                          },
                          child: Text(
                            context.read<LanguageService>().translate('continue_with_ads'),
                            style: const TextStyle(
                              color: Colors.white54,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF0055), Color(0xFFFF5588)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0055).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            await context.read<PackService>().simulatePurchase('premium_global');
            AnalyticsService().logPremiumPurchased();
            if (context.mounted) {
              if (widget.isModal) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(context, widget.nextRoute);
              }
            }
          },
          child: Center(
            child: Text(
              context.read<LanguageService>().translate('buy_premium_button'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
