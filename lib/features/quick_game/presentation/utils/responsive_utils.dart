import 'package:flutter/material.dart';

/// Calcula el tamaño responsivo basado en el ancho de la pantalla
double getResponsiveSize(
  BuildContext context, {
  required double small,
  required double medium,
  required double large,
}) {
  final width = MediaQuery.of(context).size.width;
  // Breakpoints ajustados para Nothing Phone (2400x1080)
  const breakpointSmall = 1000.0; // Móviles pequeños
  const breakpointMedium = 1700.0; // Móviles medianos/grandes como Nothing Phone

  if (width <= breakpointSmall) {
    return small * 1.2; // Incremento del 20% para mejor visibilidad
  } else if (width <= breakpointMedium) {
    return medium * 1.5; // Incremento del 15%
  } else {
    return large * 2;
  }
}
