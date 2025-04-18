import 'package:flutter/material.dart';
import 'package:awas_app/widgets/app_bar_widget.dart';
import 'package:awas_app/widgets/bottom_bar_widget.dart';

class Ajustes extends StatelessWidget {
  const Ajustes({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        notificationCount: 3, // Número de notificaciones
      ),
      bottomNavigationBar: BottomBarWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Ajustes de notificaciones'),
            trailing: Switch(value: true, onChanged: (bool value) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.integration_instructions),
            title: const Text('Integraciones'),
            subtitle: const Text('Alexa, Google Home...'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Modo oscuro'),
            trailing: Switch(value: false, onChanged: (bool value) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Sonido de alertas'),
            trailing: Switch(value: true, onChanged: (bool value) {}),
          ),
        ],
      ),
    );
  }
}
