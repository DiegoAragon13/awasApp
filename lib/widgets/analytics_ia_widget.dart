// lib/widgets/analytics_ia_widget.dart

import 'package:flutter/material.dart';

class AnalyticsIAWidget extends StatelessWidget {
  const AnalyticsIAWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Color de fondo basado en el tema
    final backgroundColor = isDarkMode
        ? theme.colorScheme.secondary
        : const Color(0xFFF8F0E9);

    // Color del texto usando directamente el textTheme
    final textColor = theme.textTheme.bodyLarge?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mensajeIA(theme, 'Niveles de gas normales en los últimos 7 días.'),
          _mensajeIA(theme, 'Se detectó un pico de temperatura el 22/04. Posible falla en regulador de gas.'),
          _mensajeIA(theme, 'Recomendación: Revisar las conexiones del sistema cada 3 meses para prevenir fugas.'),
        ],
      ),
    );
  }

  Widget _mensajeIA(ThemeData theme, String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        mensaje,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
