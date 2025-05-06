import 'package:flutter/material.dart';

class SystemPanel extends StatelessWidget {
  final bool enabled;
  const SystemPanel({required this.enabled, super.key});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? theme.colorScheme.secondary: const Color(0xFFF8F0E9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Estatus del Sistema',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Batería: 92%'),
                  SizedBox(height: 8),
                  Text('Sensores: Fine'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Wifi: Connected'),
                  SizedBox(height: 8),
                  Text('Verificación: 2 Min'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


