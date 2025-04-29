import 'package:awas_app/providers/segmented_control_provider.dart';
import 'package:awas_app/widgets/alerts_cards_widget.dart';
import 'package:awas_app/widgets/segmented_control_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awas_app/providers/AlertsProvider.dart';

class Alerts extends StatefulWidget {
  const Alerts({super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ya no usamos Provider.of aquí para los datos
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenTitle(theme: theme),
            SegmentedControlWidget(),
            Expanded(
              child: Consumer2<AlertsProvider, SegmentedControlProvider>(
                builder: (context, providerAlerts, providerSegmentedControl, _) {
                  final filteredAlerts = providerAlerts.getFilteredAlerts(providerSegmentedControl.filters);
                  return ListView.builder(
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) {
                      return AlertsCardsWidget(
                        alert: filteredAlerts[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text('Alertas', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 30),
      ],
    );
  }
}
