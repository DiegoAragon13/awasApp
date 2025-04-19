import 'package:flutter/material.dart';
import 'package:awas_app/Pages/home.dart';
import 'package:awas_app/Pages/alerts.dart';
import 'package:awas_app/Pages/analytics.dart';
import 'package:awas_app/Pages/ajustes.dart';

import 'package:awas_app/widgets/app_bar_widget.dart';
import 'package:awas_app/widgets/bottom_bar_widget.dart';




// Main container que usa BottomBarWidget
class navigationForPages extends StatefulWidget {
  const navigationForPages({super.key});

  @override
  State<navigationForPages> createState() => _navigationForPagesState();
}

class _navigationForPagesState extends State<navigationForPages> {
  int _currentIndex = 0;

  // Lista de páginas
  final List<Widget> _pages = [
    const HomePage(),
    const Alerts(),
    const analytics(),
    const Ajustes(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(notificationCount: 3),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomBarWidget(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}