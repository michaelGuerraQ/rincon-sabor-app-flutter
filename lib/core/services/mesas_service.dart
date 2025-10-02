
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';

class MesaService {

  static Future<List<Mesa>> obtenerMesas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final token = await user.getIdToken();
      final uri = Uri.parse('${Config.apiUrl}/mesas/obtener');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        final List datos = jsonResult['data'] ?? [];
        return datos.map((e) => Mesa.fromJson(e)).toList();
      } else {
        print('Error al obtener mesas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception en obtenerMesas: $e');
      return [];
    }
  }

  static Future<bool> actualizarEstadoMesa({
    required String mesaCodigo,
    required EstadoMesa nuevoEstado,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();
      final uri = Uri.parse('${Config.apiUrl}/mesas/actualizar');

      final resp = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'MesaCodigo': mesaCodigo,
          'nuevoEstado': nuevoEstado.name, // e.g. 'disponible'
        }),
      );

      if (resp.statusCode != 200) {
        print('Error al actualizar mesa: ${resp.statusCode}');
        return false;
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      print('Exception en actualizarEstadoMesa: $e');
      return false;
    }
  }
}
