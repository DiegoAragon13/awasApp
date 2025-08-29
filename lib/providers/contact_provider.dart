import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContactoEmergencia {
  final String id;
  final String nombre;
  final String telefono;

  ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
    };
  }

  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) {
    return ContactoEmergencia(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
    );
  }
}

class ContactProvider extends ChangeNotifier {
  List<ContactoEmergencia> _contactos = [];
  final int _maxContactos = 3;

  List<ContactoEmergencia> get contactos => _contactos;
  int get maxContactos => _maxContactos;
  bool get puedeAgregarContacto => _contactos.length < _maxContactos;

  ContactProvider() {
    _loadContactos();
  }

  Future<void> agregarContacto(String nombre, String telefono) async {
    if (_contactos.length >= _maxContactos) return;

    final nuevoContacto = ContactoEmergencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      telefono: telefono,
    );

    _contactos.add(nuevoContacto);
    notifyListeners();
    await _saveContactos();
  }

  Future<void> eliminarContacto(String id) async {
    _contactos.removeWhere((contacto) => contacto.id == id);
    notifyListeners();
    await _saveContactos();
  }

  Future<void> editarContacto(String id, String nuevoNombre, String nuevoTelefono) async {
    final index = _contactos.indexWhere((contacto) => contacto.id == id);
    if (index != -1) {
      _contactos[index] = ContactoEmergencia(
        id: id,
        nombre: nuevoNombre,
        telefono: nuevoTelefono,
      );
      notifyListeners();
      await _saveContactos();
    }
  }

  Future<void> _saveContactos() async {
    final prefs = await SharedPreferences.getInstance();
    final contactosJson = _contactos.map((contacto) => contacto.toJson()).toList();
    await prefs.setString('contactos_emergencia', json.encode(contactosJson));
  }

  Future<void> _loadContactos() async {
    final prefs = await SharedPreferences.getInstance();
    final contactosString = prefs.getString('contactos_emergencia');

    if (contactosString != null) {
      final contactosJson = json.decode(contactosString) as List;
      _contactos = contactosJson
          .map((contactoJson) => ContactoEmergencia.fromJson(contactoJson))
          .toList();
      notifyListeners();
    }
  }
}