import 'package:flutter/material.dart';
import 'package:awas_app/widgets/settings_cards_widget.dart';
import 'package:provider/provider.dart';
import 'package:awas_app/providers/theme_provider.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  // Estados para los switches
  bool recibirNotificaciones = true;
  bool alexa = false;
  bool sonidoAlertas = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Ajustes',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),
                // Tarjeta de Ajustes de notificaciones
                CardsAjustes(
                  titulo: 'Ajustes de notificaciones',
                  opciones: [
                    OpcionAjuste(
                      titulo: 'Recibir Notificaciónes',
                      valor: recibirNotificaciones,
                      onChanged: (value) {
                        setState(() {
                          recibirNotificaciones = value;
                        });
                      },
                    ),
                    const OpcionAjuste(
                      titulo: 'SMS',
                      esSoloTexto: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Tarjeta de Integraciones
                CardsAjustes(
                  titulo: 'Intergraciones',
                  opciones: [
                    OpcionAjuste(
                      titulo: 'Alexa',
                      valor: alexa,
                      onChanged: (value) {
                        setState(() {
                          alexa = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Tarjeta de Ajustes del sistema
                CardsAjustes(
                  titulo: 'Ajustes del sistema',
                  opciones: [
                    OpcionAjuste(
                      titulo: 'Modo oscuro',
                      valor: isDarkMode,
                      onChanged: (value) {
                        // Cambia el tema usando el provider
                        themeProvider.setThemeMode(value);
                      },
                    ),
                    OpcionAjuste(
                      titulo: 'Sonido de alertas',
                      valor: sonidoAlertas,
                      onChanged: (value) {
                        setState(() {
                          sonidoAlertas = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}