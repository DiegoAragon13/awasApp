import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SegmentedControlProvider extends ChangeNotifier {
  List<String> selectedFilters = [];

  List<String> get filters => selectedFilters;

  SegmentedControlProvider() {
    _loadFilters();
  }

  void addFilter(String filter) {
    if (!selectedFilters.contains(filter)) {
      selectedFilters.add(filter);
      _saveFilters();
      notifyListeners();
    }
  }

  void removeFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
      _saveFilters();
      notifyListeners();
    }
  }

  bool isSelected(String filter) {
    return selectedFilters.contains(filter);
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    selectedFilters = prefs.getStringList('filters') ?? [];
    notifyListeners();
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('filters', selectedFilters);
  }
}
