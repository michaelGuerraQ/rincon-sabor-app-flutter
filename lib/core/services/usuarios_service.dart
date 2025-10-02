import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';

class UsuarioService {
  static Future<Usuario?> obtenerUsuarioAutenticado() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final idToken = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/usuarios/infoUser');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        return Usuario.fromJson(jsonData['data']);
      }
    } else {
      print('Error al obtener usuario autenticado: ${response.statusCode}');
    }

    return null;
  }

  /// Obtiene todos los usuarios desde la API
  static Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    final uri = Uri.parse('${Config.apiUrl}/usuarios/listarUsuarios');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true && jsonData['data'] is List) {
        final List data = jsonData['data'];
        return data.map((e) => Usuario.fromJson(e)).toList();
      }
    } else {
      print('Error al obtener lista de usuarios: ${response.statusCode}');
    }

    return [];
  }

  static Future<bool> actualizarEstadoUsuario(
    String usuarioCodigo,
    String nuevoEstado,
  ) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.put(
      Uri.parse('${Config.apiUrl}/usuarios/actualizarEstado'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'usuarioCodigo': usuarioCodigo,
        'nuevoEstado': nuevoEstado,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Estado actualizado correctamente");
      return true;
    } else {
      print("❌ Error al actualizar estado: ${response.body}");
      return false;
    }
  }

  static Future<bool> eliminarUsuario(String codigoUsuario) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}/usuarios/eliminar/$codigoUsuario'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("✅ Usuario eliminado correctamente");
      return true;
    } else {
      print("❌ Error al eliminar usuario: ${response.body}");
      return false;
    }
  }

  static Future<bool> crearUsuario(Usuario usuario) async {
    final uri = Uri.parse('${Config.apiUrl}/usuarios/crear');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UsuarioNombre': usuario.usuarioNombre,
        'UsuarioEmail': usuario.usuarioEmail,
        'UsuarioDireccion': usuario.usuarioDireccion,
        'UsuarioTelefono': usuario.usuarioTelefono,
        'UsuarioRol': usuario.usuarioRol,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Aquí tratamos la respuesta como un objeto JSON
      try {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print("✅ Usuario creado correctamente");
          return true;
        }
        print("❌ Error al crear usuario: ${responseData['message']}");
        return false;
      } catch (e) {
        print("❌ Error al parsear la respuesta: $e");
        return false;
      }
    } else {
      print("❌ Error al crear usuario: ${response.body}");
      return false;
    }
  }

  static Future<bool> actualizarUsuario(Usuario usuario) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.put(
      Uri.parse('${Config.apiUrl}/usuarios/actualizarUsuario'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'UsuarioCodigo': usuario.usuarioCodigo,
        'UsuarioNombre': usuario.usuarioNombre,
        'UsuarioEmail': usuario.usuarioEmail,
        'UsuarioDireccion': usuario.usuarioDireccion,
        'UsuarioTelefono': usuario.usuarioTelefono,
        'UsuarioEstado': usuario.usuarioEstado,
        'UsuarioRol': usuario.usuarioRol,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Usuario actualizado correctamente");
      return true;
    } else {
      print("❌ Error al actualizar usuario: ${response.body}");
      return false;
    }
  }
}
