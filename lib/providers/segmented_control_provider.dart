import 'package:flutter/material.dart';

class SegmentedControlProvider extends ChangeNotifier {
  List<String> selectedFilters = [];

  List<String> get filters => selectedFilters;
  
  void addFilter(String filter){
    selectedFilters.add(filter);
    notifyListeners();
  }
  
  void removeFilter(String filter){
    selectedFilters.remove(filter);
    notifyListeners();
  }

}