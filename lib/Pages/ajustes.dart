import 'package:flutter/material.dart';
import 'package:awas_app/widgets/app_bar_widget.dart';
import 'package:awas_app/widgets/bottom_bar_widget.dart';

class Ajustes extends StatelessWidget {
  const Ajustes({super.key});
// HomePage separado como widget
  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Center(
      child: Text(
      'Ajustes',
      style: theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold),
       ),
      );
     }
  }