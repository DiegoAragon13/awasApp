import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awas_app/providers/panel_provider.dart';
import 'package:awas_app/widgets/system_panel_home.dart';
import '../providers/AlertsProvider.dart';
import '../widgets/alert_home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelProvider = Provider.of<PanelProvider>(context);
    final alertsProvider = Provider.of<AlertsProvider>(context);

    final recentAlerts = alertsProvider.alerts.where(
          (alert) => alert.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))),
    ).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle y panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Panel',
                      style: theme.textTheme.headlineSmall,
                    ),
                    Switch(
                      value: panelProvider.isPanelEnabled,
                      onChanged: (value) => panelProvider.togglePanel(value),
                    ),
                  ],
                ),
              ),

              // Mostrar el panel si está activado
              if (panelProvider.isPanelEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const SystemPanel(enabled: true),
                ),

              // Título de alertas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Alertas Recientes',
                  style: theme.textTheme.headlineSmall,
                ),
              ),

              // Lista de alertas recientes
              if (recentAlerts.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentAlerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final alert = recentAlerts[index];
                    return AlertCard(
                      icon: alert.type == 'Gas'
                          ? Icons.gas_meter
                          : alert.type == 'Agua'
                          ? Icons.water_drop
                          : Icons.motion_photos_on,
                      title: alert.message,
                      time:
                      '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')} - ${alert.location}',
                    );
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No hay alertas recientes.'),
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
