import 'package:flutter/material.dart';

class Pack {
  final String id;
  final String nameKey; // Clave de traducción para el nombre
  final String descriptionKey; // Clave de traducción para la descripción
  final IconData icon;
  final bool isPremium;

  const Pack({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    this.isPremium = true,
  });
}
