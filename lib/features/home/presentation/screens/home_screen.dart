import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/language_service.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_header.dart';
import '../widgets/home_buttons_section.dart';
import '../widgets/background_glows.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';
import '../widgets/floating_particle.dart';
import 'package:drinkaholic/features/league/presentation/screens/participants_screen.dart';
import 'package:drinkaholic/features/league/presentation/screens/league_list_screen.dart';

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeagueListScreen()),
      );
    } catch (e) {
      _viewModel.setError('Error al navegar a Liga: ${e.toString()}');
    }
  }

  Future<void> _navigateToElixirs() async {
    final msg = Provider.of<LanguageService>(context, listen: false).isSpanish
        ? 'Recarga de elixires próximamente'
        : 'Elixir refill coming soon';

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
              // Background color
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0B0B1A),
                ),
              ),

              // Glows
              BackgroundGlows(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              // Floating particles
              ...List.generate(
                35,
                (index) => FloatingParticle(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  index: index,
                ),
              ),

              // Main content
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
                          HomeHeader(screenWidth: screenWidth),
                          HomeButtonsSection(
                            onQuickGamePressed: () => _handleNavigation(
                              HomeViewModel.quickGameGradient,
                              Provider.of<LanguageService>(context,
                                      listen: false)
                                  .translate('play_quick'),
                              Icons.flash_on,
                              _navigateToQuickGame,
                            ),
                            onLeaguePressed: () => _handleNavigation(
                              HomeViewModel.leagueGradient,
                              Provider.of<LanguageService>(context,
                                      listen: false)
                                  .translate('play_league'),
                              Icons.emoji_events,
                              _navigateToLeague,
                            ),
                            onElixirsPressed: () => _handleNavigation(
                              HomeViewModel.elixirsGradient,
                              Provider.of<LanguageService>(context,
                                      listen: false)
                                  .translate('menu_reload_elixirs'),
                              Icons.local_drink,
                              _navigateToElixirs,
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
          );
        },
      ),
    );
  }
}
