// lib/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:awas_app/widgets/analytics_chart_carousel.dart';
import 'package:awas_app/widgets/analytics_stats_widget.dart';
import 'package:awas_app/widgets/analytics_ia_widget.dart';

class analytics extends StatelessWidget {
  const analytics({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'Análisis',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 30),

              // Widgets de estadísticas
              const AnalyticsStatsWidget(),
              const SizedBox(height: 24),

              // Título de gráficos
              Text(
                'Histórico de sensores',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Carrusel de gráficos
              const AnalyticsChartCarousel(),
              const SizedBox(height: 24),

              // Título de análisis IA
              Text(
                'Análisis de IA',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Widget de IA
              const AnalyticsIAWidget(),

              // Espacio al final para evitar que el contenido quede oculto
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}