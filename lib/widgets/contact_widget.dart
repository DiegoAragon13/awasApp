import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contact_dialog.dart';
import 'package:awas_app/providers/contact_provider.dart';

class ContactosEmergenciaWidget extends StatelessWidget {
  const ContactosEmergenciaWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        return Column(
          children: [
            // Mostrar contactos existentes
            ...contactProvider.contactos.map((contacto) =>
                _buildContactoItem(context, contacto, contactProvider)
            ).toList(),

            // Botón para agregar contacto si no se ha alcanzado el límite
            if (contactProvider.puedeAgregarContacto)
              _buildAddContactButton(context, contactProvider),

            // Mostrar mensaje si no hay contactos
            if (contactProvider.contactos.isEmpty)
              _buildEmptyState(context, contactProvider),
          ],
        );
      },
    );
  }

  Widget _buildContactoItem(BuildContext context, ContactoEmergencia contacto, ContactProvider provider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final iconColor = isDarkMode ? const Color(0xFFF8F0E9) : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.secondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.person_outline,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contacto.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contacto.telefono,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón editar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showEditDialog(context, contacto, provider),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: iconColor,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
              // Botón eliminar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showDeleteConfirmation(context, contacto, provider),
                  icon: Icon(
                    Icons.remove_outlined,
                    size: 16,
                    color: isDarkMode ? const Color(0xFFF8F0E9) : Colors.blueGrey,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactButton(BuildContext context, ContactProvider provider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final buttonColor = isDarkMode ? const Color(0xFFF8F0E9) : theme.colorScheme.tertiary.withOpacity(0.05);

    return GestureDetector(
      onTap: () => _showAddDialog(context, provider),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Agregar contacto',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ContactProvider provider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final iconColor = isDarkMode ? const Color(0xFFF8F0E9) : theme.textTheme.bodyLarge?.color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.contacts_outlined,
              size: 28,
              color: iconColor?.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin contactos configurados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega hasta 3 contactos de emergencia',
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showAddDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Agregar contacto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, ContactProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(
        onGuardar: (nombre, telefono) {
          provider.agregarContacto(nombre, telefono);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, ContactoEmergencia contacto, ContactProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(
        contactoId: contacto.id,
        nombreInicial: contacto.nombre,
        telefonoInicial: contacto.telefono,
        onGuardar: (nombre, telefono) {
          provider.editarContacto(contacto.id, nombre, telefono);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ContactoEmergencia contacto, ContactProvider provider) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Eliminar contacto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          '¿Confirmas que deseas eliminar el contacto de ${contacto.nombre}?',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.eliminarContacto(contacto.id);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}