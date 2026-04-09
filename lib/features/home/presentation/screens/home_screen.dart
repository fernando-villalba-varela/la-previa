import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/services/language_service.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_header.dart';
import '../widgets/home_buttons_section.dart';
import '../../../../core/presentation/components/neon_background_layer.dart';
import 'package:drinkaholic/features/league/presentation/screens/league_list_screen.dart';
import 'package:drinkaholic/features/league/presentation/screens/participants_screen.dart';
import '../../../../features/home/presentation/screens/premium_offer_screen.dart';
import '../../../../core/services/pack_service.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(
    Gradient gradient,
    String buttonText,
    IconData icon,
    Future<void> Function() navigationFn,
  ) async {
    _viewModel.startAnimation(gradient, buttonText, icon);
    await _animationController.forward();

    if (!mounted) return;
    await navigationFn();

    await Future.delayed(const Duration(milliseconds: 100));
    _animationController.reset();
    _viewModel.resetAnimation();
  }

  Future<void> _navigateToQuickGame() async {
    try {
      _viewModel.clearError();
      final title = Provider.of<LanguageService>(context, listen: false)
          .translate('play_quick');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParticipantsScreen(title: title),
        ),
      );
    } catch (e) {
      _viewModel.setError('Error al navegar a Partida Rápida: ${e.toString()}');
    }
  }

  Future<void> _navigateToLeague() async {
    try {
      _viewModel.clearError();
      if (!mounted) return;
      final isPremium = Provider.of<PackService>(context, listen: false).isPremium;
      if (!isPremium) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PremiumOfferScreen(
              nextRoute: MaterialPageRoute(builder: (context) => const LeagueListScreen()),
              source: 'league_gate',
            ),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeagueListScreen()),
      );
    } catch (e) {
      _viewModel.setError('Error al navegar a Liga: ${e.toString()}');
    }
  }

  Future<void> _navigateToElixirs() async {
    final Uri url = Uri.parse('https://shotest.es/productos/33-pack-degustaci%C3%B3n-2-botellas.html');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return NeonBackgroundLayer(
            showBottomRightGlow: true,
            child: Stack(
              children: [
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            HomeHeader(screenWidth: screenWidth),
                            SizedBox(height: 30.h),
                            HomeButtonsSection(
                              onQuickGamePressed: () => _handleNavigation(
                                HomeViewModel.quickGameGradient,
                                Provider.of<LanguageService>(context, listen: false).translate('play_quick'),
                                Icons.flash_on,
                                _navigateToQuickGame,
                              ),
                              onLeaguePressed: () => _handleNavigation(
                                HomeViewModel.leagueGradient,
                                Provider.of<LanguageService>(context, listen: false).translate('play_league'),
                                Icons.emoji_events,
                                _navigateToLeague,
                              ),
                              onElixirsPressed: () => _handleNavigation(
                                HomeViewModel.elixirsGradient,
                                Provider.of<LanguageService>(context, listen: false).translate('menu_reload_elixirs'),
                                Icons.local_drink,
                                _navigateToElixirs,
                              ),
                            ),
                            // Sponsors section
                            Padding(
                              padding: EdgeInsets.only(bottom: 24.h),
                              child: Column(
                                children: [
                                  Text(
                                    Provider.of<LanguageService>(context).translate('integrated_with'),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white54,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/promo.webp',
                                        width: min(screenWidth * 0.25, 90),
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 20.w),
                                      Image.asset(
                                        'assets/images/promo2.webp',
                                        width: min(screenWidth * 0.25, 90),
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Bar
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini Logo
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.webp',
                            width: 24,
                            height: 24,
                            color: const Color(0xFFFF0055),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LA PREVIA',
                            style: TextStyle(
                              color: const Color(0xFFFF0055),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFFF0055).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Right section: Language + Premium
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Premium Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PremiumOfferScreen(
                                    nextRoute: MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    source: 'home',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFCC00).withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFCC00).withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFCC00).withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Color(0xFFFFCC00),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Language Selector
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return GestureDetector(
                                onTap: () => languageService.toggleLanguage(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        languageService.isSpanish ? '🇪🇸' : '🇬🇧',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        languageService.isSpanish ? 'ES' : 'EN',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Loading overlay
                if (_viewModel.isAnimating && _viewModel.currentGradient != null)
                  LoadingOverlay(
                    opacityAnimation: _opacityAnimation,
                    iconScaleAnimation: _iconScaleAnimation,
                    gradient: _viewModel.currentGradient!,
                    buttonText: _viewModel.animatingButtonText ?? '',
                    icon: _viewModel.animatingIcon ?? Icons.flash_on,
                  ),

                // Error banner
                if (_viewModel.hasError)
                  ErrorBanner(
                    errorMessage: _viewModel.errorMessage!,
                  ),
              ],
            ),
          );
        },

      ),
    );
  }
}
