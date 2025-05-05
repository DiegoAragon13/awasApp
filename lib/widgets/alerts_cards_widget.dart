import 'package:awas_app/utils/formatters/alert_datetime_formatter.dart';
import 'package:flutter/material.dart';
import 'package:awas_app/providers/AlertsProvider.dart';
import 'package:provider/provider.dart';

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
      child: SizedBox(
        width: double.infinity,
        child: Container(
          // width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon(Icons.warning, color: Colors.red),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Text(
                            alert.message,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              // color: theme.colorScheme.primary
                              // maxLines: 2,
                              // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          alert.location,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AlertDateTimeFormatter.format(alert.timestamp),
                      style: theme.textTheme.bodySmall,
                    ),
                    ElevatedButton(onPressed: () {
                      final providerAlerts = Provider.of<AlertsProvider>(context, listen: false);
                      providerAlerts.removeAlert(alert.id);
                    }, child: Text('Borrar', style: theme.textTheme.bodySmall,)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
