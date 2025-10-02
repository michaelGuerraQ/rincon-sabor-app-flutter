import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/DTO_MenuRequest.dart';
import 'package:rincon_sabor_flutter/core/models/RecetaDetalle.dart';
import 'package:rincon_sabor_flutter/core/models/menu.dart';

class MenuService {
  /// Envía un nuevo menú usando el DTO MenuRequest
  static Future<bool> agregarMenu(
    MenuRequest dto, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();
      final uri = Uri.parse('${Config.apiUrl}/menu/agregarMenu');

      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // campos del DTO
      dto.toJson().forEach((k, v) {
        req.fields[k] =
            (v is String || v is num) ? v.toString() : json.encode(v);
      });

      // adjunta imagen: File en móvil, bytes en web
      if (imageFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath('MenuImage', imageFile.path),
        );
      } else if (imageBytes != null && imageName != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'MenuImage',
            imageBytes,
            filename: imageName,
          ),
        );
      }

      final resp = await req.send();
      // final text = await resp.stream.bytesToString();
      // print('▓ agregarMenu → ${resp.statusCode}\n$text');
      return resp.statusCode == 201;
    } catch (e) {
      // print('Exception en agregarMenu: $e');
      return false;
    }
  }

  static Future<List<Menu>> obtenerMenus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      final token = await user.getIdToken();
      final uri = Uri.parse('${Config.apiUrl}/menu/mostrarMenus');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        final List datos = jsonResult['data'] ?? [];
        // print('el menu obtenido: $datos');
        return datos.map((e) => Menu.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> eliminarMenu(String codigoMenu) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();
      final uri = Uri.parse('${Config.apiUrl}/menu/eliminarMenu/$codigoMenu');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      // print('Exception en eliminarMenu: $e');
      return false;
    }
  }

  static Future<MenuDetallado?> obtenerMenuPorCodigo(String codigo) async {
    print('Obteniendo menú con código: $codigo');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      final uri = Uri.parse('${Config.apiUrl}/menu/menuInfo/$codigo');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        final jsonData = jsonResult['data'];
        return MenuDetallado.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> actualizarMenu(MenuUpdateRequest dto) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final token = await user.getIdToken();

      final uri = Uri.parse('${Config.apiUrl}/menu/actualizarMenu');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(dto.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
