import 'package:flutter/material.dart';
import 'package:awas_app/widgets/system_panel_home.dart';
import '../widgets/alert_home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Usamos ValueNotifier para manejar el estado en un StatelessWidget
    final panelEnabled = ValueNotifier<bool>(true);

    final List<Map<String, dynamic>> alerts = [
      {
        'icon': Icons.motion_photos_on,
        'title': 'Detección de movimiento',
        'time': 'Hoy, 10:23 AM'
      },
      {
        'icon': Icons.water_drop,
        'title': 'Nivel de agua alto',
        'time': 'Hoy, 10:23 AM'
      },
      {
        'icon': Icons.gas_meter,
        'title': 'Detección de gas',
        'time': 'Hoy, 10:23 AM'
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle y panel en un ValueListenableBuilder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ValueListenableBuilder<bool>(
                  valueListenable: panelEnabled,
                  builder: (context, enabled, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Panel',
                          style: theme.textTheme.headlineSmall,
                        ),
                        Switch(
                          value: enabled,
                          onChanged: (value) => panelEnabled.value = value,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // SystemPanel solo cuando panelEnabled = true
              ValueListenableBuilder<bool>(
                valueListenable: panelEnabled,
                builder: (context, enabled, _) {
                  if (!enabled) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SystemPanel(enabled: true),
                  );
                },
              ),

              // Título de alertas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Alertas Recientes',
                  style: theme.textTheme.headlineSmall,
                ),
              ),

              // Lista de alertas
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return AlertCard(
                    icon: alert['icon'] as IconData,
                    title: alert['title'] as String,
                    time: alert['time'] as String,
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}



