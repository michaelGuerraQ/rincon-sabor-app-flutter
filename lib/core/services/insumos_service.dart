import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';

class InsumosService {
  /// Obtiene todos los insumos desde la API
  static Future<List<Insumos>> listarInsumos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/insumos/ListaInsumos');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(resp.body);
      final List data = body['data'] as List;
      return data.map((e) => Insumos.fromJson(e)).toList();
    } else {
      throw Exception('Error listando insumos: ${resp.statusCode}');
    }
  }

  /// Crea un nuevo insumo y devuelve true si tuvo éxito
  static Future<bool> crearInsumo({
    required String nombre,
    required String unidadMedida,
    required double stockActual,
    required double compraUnidad,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/insumos/agregarInsumo');

    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'InsumoNombre': nombre,
        'InsumoUnidadMedida': unidadMedida,
        'InsumoStockActual': stockActual,
        'InsumoCompraUnidad': compraUnidad,
      }),
    );

    return resp.statusCode == 201;
  }

  static Future<bool> actualizarInsumo({
    required String codigo,
    required String nombre,
    required String unidadMedida,
    required double stockActual,
    required double compraUnidad,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/insumos/actualizarInsumo');

    final resp = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'InsumoCodigo': codigo,
        'InsumoNombre': nombre,
        'InsumoUnidadMedida': unidadMedida,
        'InsumoStockActual': stockActual,
        'InsumoCompraUnidad': compraUnidad,
      }),
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(resp.body);
      return body['success'] == true;
    }
    return false;
  }
}
