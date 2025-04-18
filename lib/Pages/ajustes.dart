import 'package:flutter/material.dart';
import 'package:awas_app/widgets/app_bar_widget.dart';
import 'package:awas_app/widgets/bottom_bar_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool receiveNotifications = true;
  bool alexaIntegration = false;
  bool darkMode = false;
  bool alertSounds = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(notificationCount: 3),
      bottomNavigationBar: BottomBarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Ajustes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Ajustes de notificaciones
            _buildSettingsCard(
              title: 'Ajustes de notificaciones',
              children: [
                _buildSwitchTile(
                  title: 'Recibir Notificaciones',
                  subtitle: 'SMS',
                  value: receiveNotifications,
                  onChanged: (value) {
                    setState(() {
                      receiveNotifications = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔌 Integraciones
            _buildSettingsCard(
              title: 'Integraciones',
              children: [
                _buildSwitchTile(
                  title: 'Alexa',
                  value: alexaIntegration,
                  onChanged: (value) {
                    setState(() {
                      alexaIntegration = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ajustes del sistema
            _buildSettingsCard(
              title: 'Ajustes del sistema',
              children: [
                _buildSwitchTile(
                  title: 'Modo oscuro',
                  value: darkMode,
                  onChanged: (value) {
                    setState(() {
                      darkMode = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Sonido de alertas',
                  value: alertSounds,
                  onChanged: (value) {
                    setState(() {
                      alertSounds = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0D1B2A),
          inactiveTrackColor: const Color(0xFFD8C7BE),
        ),
      ],
    );
  }
}
