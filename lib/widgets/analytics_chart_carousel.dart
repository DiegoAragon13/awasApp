import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/chart_data.dart';

class AnalyticsChartCarousel extends StatefulWidget {
  const AnalyticsChartCarousel({super.key});

  @override
  State<AnalyticsChartCarousel> createState() => _AnalyticsChartCarouselState();
}

class _AnalyticsChartCarouselState extends State<AnalyticsChartCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<ChartConfig> _charts = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeFirestore();
  }

  Future<void> _cargarDatosDesdeFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('monitorAmbiental')
        .orderBy('fecha', descending: true)
        .limit(30)
        .get();

    List<ChartData> gasData = [];
    List<ChartData> temperaturaData = [];
    List<ChartData> movimientoData = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = (data['fecha'] as Timestamp).toDate();

      gasData.add(ChartData(timestamp, (data['gas'] ?? 0).toDouble()));
      temperaturaData.add(ChartData(timestamp, (data['temperatura'] ?? 0).toDouble()));
      movimientoData.add(ChartData(
        timestamp,
        (data['movimiento'] == 'movimiento detectado') ? 1.0 : 0.0,
      ));
    }

    // Generar datos simulados para sensores adicionales
    List<ChartData> vibracionData = _generarDatosVibracion();
    List<ChartData> sonidoData = _generarDatosSonido();
    List<ChartData> humedadData = _generarDatosHumedad();

    // Ordenar datos cronológicamente para mejor visualización
    gasData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    temperaturaData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    movimientoData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    setState(() {
      _charts = [
        ChartConfig(
          title: 'Nivel de Gas',
          subtitle: 'Concentración de gas detectada',
          color: const Color(0xFF4CAF50),
          gradientColor: const Color(0xFF81C784),
          data: gasData,
          unit: 'ppm',
          chartType: ChartType.area,
        ),
        ChartConfig(
          title: 'Temperatura',
          subtitle: 'Temperatura ambiente',
          color: const Color(0xFFFF6B35),
          gradientColor: const Color(0xFFFFAB91),
          data: temperaturaData,
          unit: '°C',
          chartType: ChartType.spline,
        ),
        ChartConfig(
          title: 'Detección de Movimiento',
          subtitle: 'Actividad del sensor PIR',
          color: const Color(0xFF2196F3),
          gradientColor: const Color(0xFF64B5F6),
          data: movimientoData,
          unit: '',
          chartType: ChartType.column,
        ),
        ChartConfig(
          title: 'Vibración',
          subtitle: 'Nivel de vibraciones detectadas',
          color: const Color(0xFF9C27B0),
          gradientColor: const Color(0xFFBA68C8),
          data: vibracionData,
          unit: 'Hz',
          chartType: ChartType.spline,
        ),
        ChartConfig(
          title: 'Nivel de Sonido',
          subtitle: 'Intensidad de ruido ambiente',
          color: const Color(0xFFFF9800),
          gradientColor: const Color(0xFFFFCC02),
          data: sonidoData,
          unit: 'dB',
          chartType: ChartType.area,
        ),
        ChartConfig(
          title: 'Humedad',
          subtitle: 'Humedad relativa del ambiente',
          color: const Color(0xFF00BCD4),
          gradientColor: const Color(0xFF4DD0E1),
          data: humedadData,
          unit: '%',
          chartType: ChartType.spline,
        ),
      ];
    });
  }

  // Generar datos simulados para vibración (0-50 Hz)
  List<ChartData> _generarDatosVibracion() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular vibraciones con picos ocasionales
      double baseVibration = 5 + random.nextDouble() * 8; // 5-13 Hz base
      if (random.nextDouble() < 0.15) {
        baseVibration += random.nextDouble() * 25; // Picos hasta 38 Hz
      }
      data.add(ChartData(timestamp, baseVibration));
    }

    return data;
  }

  // Generar datos simulados para sonido (30-90 dB)
  List<ChartData> _generarDatosSonido() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular niveles de sonido con variaciones naturales
      double baseSonido = 35 + random.nextDouble() * 20; // 35-55 dB base

      // Simular picos de ruido durante ciertas horas
      final hour = timestamp.hour;
      if (hour >= 7 && hour <= 22) {
        baseSonido += random.nextDouble() * 25; // Más ruido durante el día
      }

      data.add(ChartData(timestamp, baseSonido.clamp(30, 90)));
    }

    return data;
  }

  // Generar datos simulados para humedad (20-80%)
  List<ChartData> _generarDatosHumedad() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular humedad con variaciones graduales
      double baseHumedad = 45 + random.nextDouble() * 25; // 45-70% base

      // Variaciones según la hora (más humedad en la madrugada)
      final hour = timestamp.hour;
      if (hour >= 2 && hour <= 6) {
        baseHumedad += random.nextDouble() * 10; // Mayor humedad en la madrugada
      }

      data.add(ChartData(timestamp, baseHumedad.clamp(20, 80)));
    }

    return data;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getLatestValue(List<ChartData> data, String unit) {
    if (data.isEmpty) return 'N/A';
    final latest = data.last.value;
    if (unit.isEmpty) {
      return latest == 1.0 ? 'Detectado' : 'Sin movimiento';
    }
    return '${latest.toStringAsFixed(1)} $unit';
  }

  String _getAverageValue(List<ChartData> data, String unit) {
    if (data.isEmpty) return 'N/A';
    final average = data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
    if (unit.isEmpty) {
      final detectionRate = (average * 100).toStringAsFixed(0);
      return '$detectionRate% actividad';
    }
    return 'Prom: ${average.toStringAsFixed(1)} $unit';
  }

  Widget _buildChart(ChartConfig chart) {
    switch (chart.chartType) {
      case ChartType.area:
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('HH:mm'),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: MajorGridLines(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(8),
          series: <CartesianSeries<ChartData, DateTime>>[
            AreaSeries<ChartData, DateTime>(
              dataSource: chart.data,
              xValueMapper: (ChartData data, _) => data.timestamp,
              yValueMapper: (ChartData data, _) => data.value,
              color: chart.color.withOpacity(0.3),
              borderColor: chart.color,
              borderWidth: 2,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  chart.color.withOpacity(0.4),
                  chart.color.withOpacity(0.1),
                ],
              ),
            ),
          ],
        );

      case ChartType.spline:
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('HH:mm'),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: MajorGridLines(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(8),
          series: <CartesianSeries<ChartData, DateTime>>[
            SplineSeries<ChartData, DateTime>(
              dataSource: chart.data,
              xValueMapper: (ChartData data, _) => data.timestamp,
              yValueMapper: (ChartData data, _) => data.value,
              color: chart.color,
              width: 3,
              markerSettings: MarkerSettings(
                isVisible: true,
                height: 4,
                width: 4,
                color: chart.color,
                borderColor: Colors.white,
                borderWidth: 1,
              ),
            ),
          ],
        );

      case ChartType.column:
      default:
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('HH:mm'),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: MajorGridLines(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            minimum: 0,
            maximum: 1.2,
          ),
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(8),
          series: <CartesianSeries<ChartData, DateTime>>[
            ColumnSeries<ChartData, DateTime>(
              dataSource: chart.data,
              xValueMapper: (ChartData data, _) => data.timestamp,
              yValueMapper: (ChartData data, _) => data.value,
              width: 0.6,
              color: chart.color,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [chart.color, chart.gradientColor],
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.surface
        : Colors.white;
    final cardColor = isDarkMode
        ? theme.colorScheme.surfaceVariant
        : const Color(0xFFFAFAFA);

    return _charts.isEmpty
        ? Container(
      height: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando datos...'),
          ],
        ),
      ),
    )
        : Column(
      children: [
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con título y estadísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chart.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: chart.color,
                                ),
                              ),
                              Text(
                                chart.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Actual',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _getLatestValue(chart.data, chart.unit),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: chart.color,
                                ),
                              ),
                              Text(
                                _getAverageValue(chart.data, chart.unit),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Gráfica
                    Expanded(
                      child: _buildChart(chart),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores de página mejorados
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(context),
        ),
      ],
    );
  }

  List<Widget> _buildPageIndicator(BuildContext context) {
    return List<Widget>.generate(_charts.length, (index) {
      final isActive = index == _currentPage;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive ? 20 : 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isActive
              ? _charts[index].color
              : Colors.grey.withOpacity(0.3),
        ),
      );
    });
  }
}

// Enum para tipos de gráficas
enum ChartType { area, spline, column }

// Clase de configuración extendida
class ChartConfig {
  final String title;
  final String subtitle;
  final Color color;
  final Color gradientColor;
  final List<ChartData> data;
  final String unit;
  final ChartType chartType;

  ChartConfig({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradientColor,
    required this.data,
    required this.unit,
    required this.chartType,
  });
}