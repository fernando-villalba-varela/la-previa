import 'package:flutter/material.dart';

/// Obtiene un IconData dinámico basado en el contenido del challenge
IconData getDynamicIcon(String challenge) {
  final lowerChallenge = challenge.toLowerCase();

  // Drinking related
  if (lowerChallenge.contains('bebe') || lowerChallenge.contains('trago') || lowerChallenge.contains('shot')) {
    return Icons.local_drink;
  }

  // Party/celebration related
  if (lowerChallenge.contains('baila') || lowerChallenge.contains('canta') || lowerChallenge.contains('música')) {
    return Icons.music_note;
  }

  // Truth or questions
  if (lowerChallenge.contains('pregunta') || lowerChallenge.contains('cuenta') || lowerChallenge.contains('confiesa')) {
    return Icons.quiz;
  }

  // Social/group activities
  if (lowerChallenge.contains('todos') || lowerChallenge.contains('grupo') || lowerChallenge.contains('equipo')) {
    return Icons.group;
  }

  // Game/challenge related
  if (lowerChallenge.contains('juego') || lowerChallenge.contains('reto') || lowerChallenge.contains('desafío')) {
    return Icons.sports_esports;
  }

  // Love/romantic related
  if (lowerChallenge.contains('amor') || lowerChallenge.contains('besa') || lowerChallenge.contains('pareja')) {
    return Icons.favorite;
  }

  // Action/movement related
  if (lowerChallenge.contains('salta') || lowerChallenge.contains('corre') || lowerChallenge.contains('mueve')) {
    return Icons.directions_run;
  }

  // Phone/social media related
  if (lowerChallenge.contains('teléfono') || lowerChallenge.contains('mensaje') || lowerChallenge.contains('llamada')) {
    return Icons.phone;
  }

  // Time related
  if (lowerChallenge.contains('minutos') || lowerChallenge.contains('tiempo') || lowerChallenge.contains('segundo')) {
    return Icons.timer;
  }

  // Star/special challenges
  if (lowerChallenge.contains('especial') || lowerChallenge.contains('estrella') || lowerChallenge.contains('premio')) {
    return Icons.star;
  }

  // Default drink icon
  return Icons.local_drink;
}
