import 'package:flutter/material.dart';

class ChartData {
  final DateTime timestamp;
  final double value;

  ChartData(this.timestamp, this.value);
}

class ChartConfig {
  final String title;
  final Color color;
  final List<ChartData> data;

  ChartConfig({
    required this.title,
    required this.color,
    required this.data,
  });
}