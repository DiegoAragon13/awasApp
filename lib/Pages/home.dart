import 'package:flutter/material.dart';


import 'package:awas_app/Pages/alerts.dart';
import 'package:awas_app/Pages/analytics.dart';
import 'package:awas_app/Pages/ajustes.dart';

// HomePage separado como widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        'Bienvenido a AWAS APP',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


