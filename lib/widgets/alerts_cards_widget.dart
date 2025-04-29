import 'package:flutter/material.dart';
import 'package:awas_app/providers/AlertsProvider.dart';

class AlertsCardsWidget extends StatelessWidget {
  final Alert alert;
  const AlertsCardsWidget({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Color de fondo adaptado al tema
    final cardColor =
        isDarkMode ? theme.colorScheme.secondary : const Color(0xFFF8F0E9);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(alert.timestamp.toString()),
                  ElevatedButton(onPressed: () {
                  }, child: Text('Borrar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
