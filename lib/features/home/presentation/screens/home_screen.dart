import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../../core/presentation/components/drinkaholic_button.dart';
import '../widgets/floating_particle.dart';
import 'package:drinkaholic/features/league/presentation/screens/participants_screen.dart';
import 'package:drinkaholic/features/league/presentation/screens/league_list_screen.dart';
import 'package:drinkaholic/features/quick_game/presentation/screens/quick_game_screen.dart';
import '../../../../core/services/consent_and_ad_service.dart';
import '../../../../constants/button_config.dart';
import 'dart:math';

import '../../../../core/services/database_service_v2.dart';
import '../../../../core/services/consent_and_ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _iconMoveAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;

  bool _isAnimating = false;
  Gradient? _currentGradient;
  String? _animatingButtonText;
  IconData? _animatingIcon;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _iconMoveAnimation = Tween<double>(
      begin: 0.0,
      end: -200.0, // Move upward for rocket launch
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _startAnimatedNavigation(
    Gradient gradient,
    String buttonText,
    IconData icon,
    VoidCallback onComplete,
  ) async {
    setState(() {
      _isAnimating = true;
      _currentGradient = gradient;
      _animatingButtonText = buttonText;
      _animatingIcon = icon;
    });

    await _animationController.forward();

    onComplete();

    await Future.delayed(const Duration(milliseconds: 100));
    _animationController.reset();
    setState(() {
      _isAnimating = false;
      _currentGradient = null;
      _animatingButtonText = null;
      _animatingIcon = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0B0B1A), // Deep Night
                ),
              ),
              // Glow top-left
              Positioned(
                top: -screenHeight * 0.1,
                left: -screenWidth * 0.3,
                child: Container(
                  width: screenWidth * 1.2,
                  height: screenWidth * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8A2BE2).withOpacity(0.2), // Neon Violet
                        Colors.transparent,
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),
              ),
              // Glow bottom-right
              Positioned(
                bottom: -screenHeight * 0.1,
                right: -screenWidth * 0.4,
                child: Container(
                  width: screenWidth * 1.2,
                  height: screenWidth * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF0055).withOpacity(0.15), // Crimson Fiesta
                        Colors.transparent,
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),
              ),
              ...List.generate(
                35,
                (index) => FloatingParticle(screenWidth: screenWidth, screenHeight: screenHeight, index: index),
              ),

              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 20.h),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            // Logo above title
                            Image.asset(
                              'assets/images/logo.png',
                              width: min(screenWidth * 0.4, 180),
                              height: min(screenWidth * 0.4, 180),
                              fit: BoxFit.contain,
                            ),
                            
                            SizedBox(height: 20.h),

                            // Title with epic styling connected to background
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outline stroke for readability
                                Text(
                                  'LA PREVIA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: min(screenWidth * 0.12, 88),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 6,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = Colors.black.withOpacity(0.7),
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF00FFFF), // Electric Cyan
                                      Color(0xFFFF0055), // Crimson Fiesta
                                      Color(0xFFFF8C00), // Fiery Orange
                                    ],
                                    stops: [0.1, 0.5, 0.9],
                                  ).createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Text(
                                    'LA PREVIA',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: min(screenWidth * 0.12, 88),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 6,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF00FFFF).withOpacity(0.6),
                                          blurRadius: 20,
                                          offset: const Offset(-2, -2),
                                        ),
                                        Shadow(
                                          color: const Color(0xFFFF0055).withOpacity(0.6),
                                          blurRadius: 25,
                                          offset: const Offset(0, 2),
                                        ),
                                        Shadow(
                                          color: const Color(0xFFFF8C00).withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(2, 2),
                                        ),
                                        const Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(2, 4)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 6.h),
                            Text(
                              'Powered by',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xCCFFFFFF),
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            
                            SizedBox(height: 16.h), // Increased from 8.h to 16.h
                            
                            // Promo image
                            // Promo images
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/promo.png',
                                  width: min(screenWidth * 0.25, 90),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 10.w),
                                Image.asset(
                                  'assets/images/promo2.png',
                                  width: min(screenWidth * 0.25, 90),
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                          
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (context) {
                                final config = _getQuickGameButtonConfig(context);
                                return DrinkaholicButton(
                                  onPressed: config.onTap,
                                  label: config.text,
                                  icon: config.icon,
                                  variant: DrinkaholicButtonVariant.primary,
                                );
                              },
                            ),
                            SizedBox(height: 18.h),



                            Builder(
                              builder: (context) {
                                final config = _getLeagueButtonConfig(context);
                                return DrinkaholicButton(
                                  onPressed: config.onTap,
                                  label: config.text,
                                  icon: config.icon,
                                  variant: DrinkaholicButtonVariant.secondary,
                                );
                              },
                            ),
                            SizedBox(height: 18.h),

                            Builder(
                              builder: (context) {
                                final config = _getElixirsButtonConfig(context);
                                return DrinkaholicButton(
                                  onPressed: config.onTap,
                                  label: config.text,
                                  icon: config.icon,
                                  variant: DrinkaholicButtonVariant.outline,
                                );
                              },
                            ),
                            SizedBox(height: 24.h),
                            const PrivacyOptionsButton(),
                          ],
                        ),
                      ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Language Toggle Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return GestureDetector(
                      onTap: () => languageService.toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
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
              ),

              if (_isAnimating && _currentGradient != null)
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      decoration: BoxDecoration(gradient: _currentGradient),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _iconScaleAnimation,
                              child: Icon(
                                _animatingIcon,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 60),
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '$_animatingButtonText...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (_viewModel.hasError)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade600, Colors.red.shade800]),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: const Color(0x4DF44336), blurRadius: 15, spreadRadius: 2)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToQuickGame() {
    try {
      _viewModel.clearError();
      final title = Provider.of<LanguageService>(context, listen: false).translate('play_quick'); // Use translated title
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ParticipantsScreen(title: title)),
      );
    } catch (e) {
      _viewModel.setError('Error al navegar a Partida Rápida: ${e.toString()}');
    }
  }

  void _navigateToLeague() {
    try {
      _viewModel.clearError();
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LeagueListScreen()));
    } catch (e) {
      _viewModel.setError('Error al navegar a Liga: ${e.toString()}');
    }
  }

  void _navigateToElixirs() {
    // Placeholder function for now
    final msg = Provider.of<LanguageService>(context, listen: false).isSpanish 
        ? 'Recarga de elixires próximamente' 
        : 'Elixir refill coming soon';
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  ButtonConfig _getQuickGameButtonConfig(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final text = languageService.translate('play_quick');
    return ButtonConfig(
      text: text,
      icon: Icons.flash_on,
      gradient: HomeViewModel.quickGameGradient,
      onTap: () {
        _startAnimatedNavigation(HomeViewModel.quickGameGradient,
            text, Icons.flash_on, _navigateToQuickGame);
      },
    );
  }

  ButtonConfig _getLeagueButtonConfig(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final text = languageService.translate('play_league');
    return ButtonConfig(
      text: text,
      icon: Icons.emoji_events,
      gradient: HomeViewModel.leagueGradient,
      onTap: () {
        _startAnimatedNavigation(HomeViewModel.leagueGradient, text,
            Icons.emoji_events, _navigateToLeague);
      },
    );
  }

  ButtonConfig _getElixirsButtonConfig(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final text = languageService.translate('menu_reload_elixirs');
    return ButtonConfig(
      text: text,
      icon: Icons.local_drink,
      gradient: HomeViewModel.elixirsGradient,
      onTap: () {
        _startAnimatedNavigation(HomeViewModel.elixirsGradient,
            text, Icons.local_drink, _navigateToElixirs);
      },
    );
  }
}



