import 'package:flutter/material.dart';
import '../../../../core/models/game_state.dart';

enum PackThemeType {
  classic,
  christmas,
  bar,
  home,
  valentine,
}

extension PackThemeExtension on GameState {
  PackThemeType get packType {
    if (currentTemplateId == null) return PackThemeType.classic;
    
    final id = currentTemplateId!.toLowerCase();
    if (id.startsWith('xmas_')) return PackThemeType.christmas;
    if (id.startsWith('bar_')) return PackThemeType.bar;
    if (id.startsWith('home_')) return PackThemeType.home;
    if (id.startsWith('val_') || id.startsWith('valentine_')) return PackThemeType.valentine;
    
    return PackThemeType.classic;
  }

  /// Returns the primary gradient for the current pack
  List<Color> get themeGradient {
    switch (packType) {
      case PackThemeType.christmas:
        return [
          const Color(0xFFB71C1C).withOpacity(0.4), // Deep Red
          const Color(0xFF1B5E20).withOpacity(0.2), // Deep Green
        ];
      case PackThemeType.bar:
        return [
          const Color(0xFFFFA000).withOpacity(0.4), // Amber
          const Color(0xFF3E2723).withOpacity(0.2), // Dark Brown
        ];
      case PackThemeType.home:
        return [
          const Color(0xFF8D6E63).withOpacity(0.4), // Warm Brown
          const Color(0xFFD7CCC8).withOpacity(0.2), // Warm Beige
        ];
      case PackThemeType.valentine:
        return [
          const Color(0xFFE91E63).withOpacity(0.4), // Pink
          const Color(0xFFAD1457).withOpacity(0.2), // Deep Pink
        ];
      case PackThemeType.classic:
      default:
        return [
          const Color(0xFFFFFFFF).withOpacity(0.25),
          const Color(0xFFFFFFFF).withOpacity(0.10),
        ];
    }
  }

  /// Returns the border color for the current pack
  Color get themeBorderColor {
    switch (packType) {
      case PackThemeType.christmas:
        return const Color(0xFFFFD700).withOpacity(0.6); // Gold
      case PackThemeType.bar:
        return const Color(0xFFFFD700).withOpacity(0.6); // Gold
      case PackThemeType.home:
        return const Color(0xFF5D4037).withOpacity(0.6); // Deep Brown
      case PackThemeType.valentine:
        return const Color(0xFFFFC1E3).withOpacity(0.6); // Light Pink
      case PackThemeType.classic:
      default:
        return Colors.white.withOpacity(0.4);
    }
  }

  /// Returns the primary glow/shadow color for the current pack
  Color get themeGlowColor {
    switch (packType) {
      case PackThemeType.christmas:
        return const Color(0xFFFFD700); // Gold
      case PackThemeType.bar:
        return const Color(0xFFFFA000); // Amber
      case PackThemeType.home:
        return const Color(0xFF8D6E63); // Warm Brown
      case PackThemeType.valentine:
        return const Color(0xFFF48FB1); // Rose Pink
      case PackThemeType.classic:
      default:
        return Colors.cyan;
    }
  }

  /// Returns the icon for the current pack
  IconData? get themeIcon {
    switch (packType) {
      case PackThemeType.christmas:
        return Icons.ac_unit; // Snowflakes/Christmas
      case PackThemeType.bar:
        return Icons.local_bar; // Beer/Bar
      case PackThemeType.home:
        return Icons.home; // Home
      case PackThemeType.valentine:
        return Icons.favorite; // Heart/Love
      case PackThemeType.classic:
      default:
        return null;
    }
  }

  /// Returns a decoration for the card based on the pack
  BoxDecoration get cardDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: themeGradient,
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: themeBorderColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 25,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: themeGlowColor.withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 0),
          spreadRadius: -5,
        ),
      ],
    );
  }
}
