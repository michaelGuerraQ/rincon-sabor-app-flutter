import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';

class CategoriaService {
  static Future<List<Categoria>> obtenerCategorias() async {
    final uri = Uri.parse('${Config.apiUrl}/categorias/mostrarCategorias');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      final List datos = jsonResult['data'];
      return datos.map((e) => Categoria.fromJson(e)).toList();
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  static Future<bool> agregarCategoria({
    required String categoriaNombre,
    required String categoriaDescripcion,
    String categoriaEstado = 'A', // Estado por defecto: Activo
  }) async {
    final uri = Uri.parse('${Config.apiUrl}/categorias/agregarCategoria');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'CategoriaNombre': categoriaNombre,
        'CategoriaDescripcion': categoriaDescripcion,
        'CategoriaEstado': categoriaEstado,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Error HTTP: ${response.statusCode}, ${response.body}');
    }
  }

  static Future<bool> actualizarCategoria({
      required String categoriaCodigo,
      required String categoriaNombre,
      required String categoriaDescripcion,
      required String categoriaEstado,
    }) async {
      final uri = Uri.parse('${Config.apiUrl}/categorias/actualizarCategoria');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'CategoriaCodigo': categoriaCodigo,
          'CategoriaNombre': categoriaNombre,
          'CategoriaDescripcion': categoriaDescripcion,
          'CategoriaEstado': categoriaEstado,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}, ${response.body}');
      }
    }

  static Future<bool> eliminarCategoria(String codigoCategoria) async {
    
    final uri = Uri.parse('${Config.apiUrl}/categorias/eliminarCategoria/$codigoCategoria');
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error HTTP: ${response.statusCode}, ${response.body}');
    }
  }
}