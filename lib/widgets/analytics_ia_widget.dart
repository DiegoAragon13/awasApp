import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/AlertsProvider.dart';
import '../services/gemini_service.dart';

class AnalyticsIAWidget extends StatefulWidget {
  const AnalyticsIAWidget({super.key});

  @override
  State<AnalyticsIAWidget> createState() => _AnalyticsIAWidgetState();
}

class _AnalyticsIAWidgetState extends State<AnalyticsIAWidget> {
  String? _recommendations;
  bool _isLoading = false;
  String? _error;
  int _updatesToday = 0;
  DateTime? _lastUpdateDate;

  static const int maxUpdatesPerDay = 7;

  @override
  void initState() {
    super.initState();
    GeminiService.initialize();
    _loadUpdateState(); // No actualiza recomendaciones automáticamente
  }

  Future<void> _loadUpdateState() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString('ia_update_date');
    final today = DateTime.now();

    // Cargar últimas recomendaciones guardadas
    _recommendations = prefs.getString('last_recommendations');

    if (storedDate != null) {
      final lastDate = DateTime.parse(storedDate);
      if (_isSameDay(today, lastDate)) {
        _updatesToday = prefs.getInt('ia_update_count') ?? 0;
      } else {
        _updatesToday = 0;
        await prefs.setInt('ia_update_count', 0);
        await prefs.setString('ia_update_date', today.toIso8601String());
      }
    } else {
      await prefs.setString('ia_update_date', today.toIso8601String());
      await prefs.setInt('ia_update_count', 0);
    }

    setState(() {
      _lastUpdateDate = today;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<bool> _canUpdateRecommendations() async {
    if (_updatesToday >= maxUpdatesPerDay) return false;

    final prefs = await SharedPreferences.getInstance();
    _updatesToday += 1;
    await prefs.setInt('ia_update_count', _updatesToday);
    return true;
  }

  Future<void> _loadRecommendations() async {
    final canUpdate = await _canUpdateRecommendations();
    if (!canUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has alcanzado el límite de 7 actualizaciones de IA por día.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
      final alerts = alertsProvider.alerts;
      final riskLevel = alertsProvider.calculateRiskLevel();

      final recommendations = await GeminiService.getRecommendations(alerts, riskLevel);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_recommendations', recommendations);

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar recomendaciones: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? theme.colorScheme.secondary
        : const Color(0xFFF8F0E9);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Análisis IA',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_isLoading)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRecommendations,
                  tooltip: 'Actualizar recomendaciones',
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            _buildLoadingWidget(theme)
          else if (_error != null)
            _buildErrorWidget(theme)
          else if (_recommendations != null)
              _buildRecommendationsWidget(theme)
            else
              _buildEmptyWidget(theme),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Analizando alertas con IA...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsWidget(ThemeData theme) {
    final recommendations = _recommendations!.split('•')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();

    return Column(
      children: recommendations.map((recommendation) {
        return _mensajeIA(theme, recommendation);
      }).toList(),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Sistema funcionando normalmente',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensajeIA(ThemeData theme, String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              mensaje,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
