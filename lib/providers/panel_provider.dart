import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanelProvider extends ChangeNotifier {
  bool _isPanelEnabled = true;

  bool get isPanelEnabled => _isPanelEnabled;

  PanelProvider() {
    _loadState();
  }

  Future<void> togglePanel(bool value) async {
    _isPanelEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('panel_enabled', value);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _isPanelEnabled = prefs.getBool('panel_enabled') ?? true;
    notifyListeners();
  }
}