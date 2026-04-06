import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/pack_service.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import '../../../../core/presentation/components/neon_header.dart';

class PremiumOfferScreen extends StatelessWidget {
  final Route nextRoute;
  final bool isModal;

  const PremiumOfferScreen({
    super.key,
    required this.nextRoute,
    this.isModal = false,
  });

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF0055), size: 100),
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
                      _buildBuyButton(context),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          if (isModal) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(context, nextRoute);
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
            // Simulate premium purchase
            await context.read<PackService>().simulatePurchase('premium_global');
            if (context.mounted) {
              if (isModal) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(context, nextRoute);
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
