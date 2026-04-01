import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/models/player.dart';
import '../../../../../../core/services/language_service.dart';

class StreakMessagesSection extends StatelessWidget {
  final List<Player> players;
  final Map<int, String> streakMessages;
  final Animation<double>? glowAnimation;
  final bool isSmallScreen;

  const StreakMessagesSection({
    super.key,
    required this.players,
    required this.streakMessages,
    this.glowAnimation,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar solo los mensajes que no están vacíos
    final messagesWithContent =
        streakMessages.entries.where((entry) => entry.value.isNotEmpty).toList();

    if (messagesWithContent.isEmpty) return const SizedBox.shrink();

    // Si el controlador no está inicializado, mostrar contenedor sin animación
    if (glowAnimation == null) {
      return _buildStaticSection(context, messagesWithContent);
    }

    return AnimatedBuilder(
      animation: glowAnimation!,
      builder: (context, child) {
        final animationValue = glowAnimation?.value ?? 0.0;
        return _buildAnimatedSection(
          context,
          messagesWithContent,
          animationValue,
        );
      },
    );
  }

  Widget _buildStaticSection(
    BuildContext context,
    List<MapEntry<int, String>> messagesWithContent,
  ) {
    return Container(
      margin: EdgeInsets.only(top: isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreakingNewsHeader(context),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ...messagesWithContent.map(
            (entry) => _buildStreakMessage(entry, context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(
    BuildContext context,
    List<MapEntry<int, String>> messagesWithContent,
    double animationValue,
  ) {
    return Container(
      margin: EdgeInsets.only(top: isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.lerp(
            const Color(0xFF228B22).withOpacity(0.4),
            const Color(0xFF32CD32).withOpacity(0.9),
            animationValue,
          )!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(
              const Color(0xFF228B22).withOpacity(0.2),
              const Color(0xFF32CD32).withOpacity(0.6),
              animationValue,
            )!,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreakingNewsHeader(context),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ...messagesWithContent.map(
            (entry) => _buildStreakMessage(entry, context),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakingNewsHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFCC0000).withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCC0000).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '🔔 ',
              style: TextStyle(
                fontSize: isSmallScreen ? 15.0 : 18.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: 'BREAKING',
              style: TextStyle(
                color: const Color(0xFFCC0000),
                fontSize: isSmallScreen ? 15.0 : 18.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: const Color(0xFFCC0000).withOpacity(0.7),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            TextSpan(
              text: ' ',
              style: TextStyle(
                fontSize: isSmallScreen ? 15.0 : 18.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: 'NEWS',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 15.0 : 18.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 6,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            TextSpan(
              text: Provider.of<LanguageService>(context)
                  .translate('breaking_news_intro'),
              style: TextStyle(
                color: const Color(0xFFCC0000),
                fontSize: isSmallScreen ? 15.0 : 18.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakMessage(MapEntry<int, String> entry, BuildContext context) {
    final message = entry.value;

    // Determinar si es racha de victorias o derrotas
    final isLossStreak = message.contains('rata asquerosa');
    final backgroundColor =
        isLossStreak ? Colors.red.withOpacity(0.2) : Colors.orange.withOpacity(0.2);
    final iconColor = isLossStreak ? Colors.red : Colors.orange;
    final icon = isLossStreak ? Icons.cleaning_services : Icons.emoji_events;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 13.0 : 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
