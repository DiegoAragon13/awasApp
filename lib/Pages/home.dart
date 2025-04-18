import 'package:flutter/material.dart';
import 'package:awas_app/widgets/app_bar_widget.dart';
import 'package:awas_app/widgets/bottom_bar_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        notificationCount: 3, //notficacioens
      ),
      bottomNavigationBar: BottomBarWidget(),
      body: Center(
        child: Text(
          'Bienvenido a AWAS APP',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
