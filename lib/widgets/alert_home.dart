import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  const AlertCard({required this.icon, required this.title, required this.time, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? theme.colorScheme.secondary: const Color(0xFFF8F0E9);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: theme.textTheme.bodyLarge),
          ),
          Text(time, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
