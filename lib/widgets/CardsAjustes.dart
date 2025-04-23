import 'package:flutter/material.dart';

class CardsAjustes extends StatelessWidget {
  final String titulo;
  final List<OpcionAjuste> opciones;

  const CardsAjustes({
    Key? key,
    required this.titulo,
    required this.opciones,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Color de fondo adaptado al tema
    final cardColor = isDarkMode
        ? theme.colorScheme.secondary
        : const Color(0xFFF8F0E9);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            ...opciones.map((opcion) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: opcion,
            )),
          ],
        ),
      ),
    );
  }
}

class OpcionAjuste extends StatelessWidget {
  final String titulo;
  final bool valor;
  final Function(bool)? onChanged;
  final bool esSoloTexto;

  const OpcionAjuste({
    Key? key,
    required this.titulo,
    this.valor = false,
    this.onChanged,
    this.esSoloTexto = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          if (!esSoloTexto)
            Switch(
              value: valor,
              onChanged: onChanged,
              activeTrackColor: theme.primaryColor,
              activeColor: Colors.white,
            ),
        ],
      ),
    );
  }
}