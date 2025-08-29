// lib/models/contacto_emergencia.dart

class ContactoEmergencia {
  String nombre;
  String numero;

  ContactoEmergencia({required this.nombre, required this.numero});

  // Método para verificar si el contacto está vacío
  bool get isEmpty => nombre.isEmpty && numero.isEmpty;

  // Método para crear una copia del contacto
  ContactoEmergencia copyWith({
    String? nombre,
    String? numero,
  }) {
    return ContactoEmergencia(
      nombre: nombre ?? this.nombre,
      numero: numero ?? this.numero,
    );
  }

  // Método para convertir a Map (útil para persistencia)
  Map<String, String> toMap() {
    return {
      'nombre': nombre,
      'numero': numero,
    };
  }

  // Método para crear desde Map
  factory ContactoEmergencia.fromMap(Map<String, String> map) {
    return ContactoEmergencia(
      nombre: map['nombre'] ?? '',
      numero: map['numero'] ?? '',
    );
  }
}