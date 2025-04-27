import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awas_app/providers/AlertsProvider.dart';
import '../providers/segmented_control_provider.dart';

class AnalyticsStatsWidget extends StatelessWidget {
  const AnalyticsStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Obtener nuestros proveedores
    final alertsProvider = Provider.of<AlertsProvider>(context);
    final filterProvider = Provider.of<SegmentedControlProvider>(context);

    // Obtener el recuento de alertas filtradas y el nivel de riesgo
    final alertCount = filterProvider.selectedFilters.isEmpty
        ? alertsProvider.alertCount
        : alertsProvider.getFilteredAlertCount(filterProvider.selectedFilters);

    final riskLevel = alertsProvider.calculateRiskLevel();

    // Definir colores para los niveles de riesgo
    Color riskColor;
    switch (riskLevel) {
      case 'Alto':
        riskColor = Colors.red;
        break;
      case 'Medio':
        riskColor = Colors.orange;
        break;
      case 'Bajo':
        riskColor = Colors.green;
        break;
      default:
        riskColor = Colors.blue;
    }

    // Color de fondo basado en el tema
    final backgroundColor = isDarkMode
        ? theme.colorScheme.secondary
        : const Color(0xFFF8F0E9);

    return Row(
      children: [
        // Total de alertas
        Expanded(
          child: Container(
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
                Text(
                  'Total de alertas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$alertCount',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (filterProvider.selectedFilters.isNotEmpty)
                  Text(
                    'Filtrado: ${filterProvider.selectedFilters.join(", ")}',
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Nivel de riesgo
        Expanded(
          child: Container(
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
                Text(
                  'Nivel de Riesgo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(
                      riskLevel,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}