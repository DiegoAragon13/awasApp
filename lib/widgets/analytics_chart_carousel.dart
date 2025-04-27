import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_data.dart';

class AnalyticsChartCarousel extends StatefulWidget {
  const AnalyticsChartCarousel({super.key});

  @override
  State<AnalyticsChartCarousel> createState() => _AnalyticsChartCarouselState();
}

class _AnalyticsChartCarouselState extends State<AnalyticsChartCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<ChartConfig> _charts = [
    ChartConfig(
      title: 'Actividad de Gas',
      color: const Color(0xFF233656),
      data: generarDatosDePrueba(valorMax: 80),
    ),
    ChartConfig(
      title: 'Temperatura',
      color: Colors.orange,
      data: generarDatosDePrueba(valorMax: 35),
    ),
    ChartConfig(
      title: 'Humedad',
      color: Colors.blue,
      data: generarDatosDePrueba(valorMax: 100),
    ),
    ChartConfig(
      title: 'Sonido',
      color: Colors.purple,
      data: generarDatosDePrueba(valorMax: 120),
    ),
    ChartConfig(
      title: 'Vibraciones',
      color: Colors.green,
      data: generarDatosDePrueba(valorMax: 50),
    ),
    ChartConfig(
      title: 'Movimiento (PIR)',
      color: Colors.red,
      data: generarDatosDePrueba(valorMax: 1, esEntero: true),
    ),
  ];

  static List<ChartData> generarDatosDePrueba({
    required double valorMax,
    bool esEntero = false,
  }) {
    final now = DateTime.now();
    final List<ChartData> datos = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      double value = (valorMax * (7 - i) / 7) % (valorMax + 1);

      if (esEntero) {
        value = value.round().toDouble();
      }

      datos.add(ChartData(day, value));
    }

    return datos;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.secondary
        : const Color(0xFFF8F0E9); // Color personalizado en modo claro

    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _charts.length,
            itemBuilder: (context, index) {
              final chart = _charts[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chart.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          isVisible: false,
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries<ChartData, DateTime>>[
                          ColumnSeries<ChartData, DateTime>(
                            dataSource: chart.data,
                            xValueMapper: (ChartData data, _) => data.timestamp,
                            yValueMapper: (ChartData data, _) => data.value,
                            width: 0.8,
                            color: chart.color,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(context),
        ),
      ],
    );
  }

  List<Widget> _buildPageIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return List<Widget>.generate(_charts.length, (index) {
      return Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index == _currentPage
              ? theme.colorScheme.primary // El actual usa primary
              : Colors.grey.withOpacity(0.4),
        ),
      );
    });
  }
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
