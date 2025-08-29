import 'package:flutter/material.dart';
import 'package:awas_app/widgets/settings_cards_widget.dart';
import 'package:provider/provider.dart';
import 'package:awas_app/providers/theme_provider.dart';
import 'package:awas_app/providers/contact_provider.dart'; // Importa el nuevo provider
import 'package:awas_app/widgets/contact_widget.dart'; // Importa el nuevo widget

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
                      titulo: 'Recibir Notificaciónes SMS',
                      valor: recibirNotificaciones,
                      onChanged: (value) {
                        setState(() {
                          recibirNotificaciones = value;
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
                const SizedBox(height: 20),
                // Tarjeta de contactos de emergencia - NUEVA IMPLEMENTACIÓN
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? theme.colorScheme.secondary
                        : const Color(0xFFF8F0E9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contactos de emergencia',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Configura hasta 3 contactos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Consumer<ContactProvider>(
                              builder: (context, contactProvider, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${contactProvider.contactos.length}/${contactProvider.maxContactos}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? const Color(0xFFF8F0E9) : theme.colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Widget de contactos de emergencia
                        const ContactosEmergenciaWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}