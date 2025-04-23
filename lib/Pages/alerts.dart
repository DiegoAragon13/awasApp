// lib/screens/home_screen.dart
import 'package:awas_app/widgets/segmented_control_widget.dart';
import 'package:flutter/material.dart';

class Alerts extends StatelessWidget {
  const Alerts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenTitle(theme: theme),
            SegmentedControlWidget(),
          ],
        ),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    super.key,
    required this.theme,
  });

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
