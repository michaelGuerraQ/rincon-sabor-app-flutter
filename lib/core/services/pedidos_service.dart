// pedidos_service.dart

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';

class PedidosService {
  /// Obtiene los pedidos asociados a una mesa específica.
  static Future<List<Pedido>> fetchPedidosPorMesa(String mesaCodigo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final token = await user.getIdToken();
    final uri = Uri.parse(
      '${Config.apiUrl}/pedidos/obtenerPorMesas/$mesaCodigo',
    );

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al conectar con el servidor: ${resp.statusCode}');
    }
    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Respuesta inválida');
    }
    final data = body['data'] as List;
    print('pedidos obtenerPorMesas: $data');
    return data.map((e) => Pedido.fromJson(e)).toList();
  }

  // Método para actualizar los detalles de un pedido
  static Future<bool> actualizarDetallesPedido({
    required String pedidoCodigo,
    required List<Map<String, dynamic>> detalles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/pedidos/actualizarDetallesPedido');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'PedidoCodigo': pedidoCodigo, 'Detalles': detalles}),
    );

    if (resp.statusCode != 200) {
      print('Error: ${resp.body}');
      return false;
    }

    final body = json.decode(resp.body);
    return body['success'] == true;
  }

  /// Lanza una excepción con el mensaje de error del backend
  static Future<void> crearPedido({
    required String mesaCodigo,
    required List<DetallePedido> detalles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'Usuario no autenticado';

    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/pedidos/crearPedido');

    final body = {
      'MesaCodigo': mesaCodigo,
      'Detalles': detalles.map((d) => d.toCreationMap()).toList(),
    };

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201 || jsonBody['success'] != true) {
      throw jsonBody['message'] ?? 'Error desconocido al crear pedido';
    }
  }

  static Future<bool> borrarPedido(String pedidoCodigo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/pedidos/eliminar/$pedidoCodigo');
    final resp = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) return false;
    final body = json.decode(resp.body) as Map<String, dynamic>;
    return body['success'] == true;
  }

  /// Obtiene los pedidos activos del usuario autenticado.
  /// Un pedido se considera activo si tiene un estado de "En preparación".
  static Future<List<Pedido>> fetchPedidosActivos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/pedidos/activos');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (kDebugMode) {
      print('respues del pedidos activos: ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw Exception('Error al obtener pedidos activos: ${resp.statusCode}');
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Respuesta inválida');
    }

    final data = body['data'] as List;
    return data.map((e) => Pedido.fromJson(e)).toList();
  }

  /// Actualiza el estado de un detalle de pedido específico.
  /// Retorna true si la actualización fue exitosa, false en caso contrario.
  static Future<bool> actualizarEstadoDetallePedido({
    required String detallePedidoCodigo,
    required String nuevoEstado,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final token = await user.getIdToken();
      final uri = Uri.parse(
        '${Config.apiUrl}/pedidos/actualizarEstadoDetalle/$detallePedidoCodigo',
      );

      final resp = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'nuevoEstado': nuevoEstado}),
      );

      if (resp.statusCode != 200) {
        print('Error al actualizar estado del detalle: ${resp.body}');
        return false;
      }

      final body = json.decode(resp.body) as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      print('Error en actualizarEstadoDetallePedido: $e');
      return false;
    }
  }

  /// Actualiza el estado de un pedido específico.
  /// Retorna true si la actualización fue exitosa, false en caso contrario.
  static Future<bool> actualizarEstadoPedido({
    required String pedidoCodigo,
    required String nuevoEstado,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdToken();
    final uri = Uri.parse(
      '${Config.apiUrl}/pedidos/actualizarEstadoPedido/$pedidoCodigo',
    );

    final resp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'nuevoEstado': nuevoEstado}),
    );

    if (resp.statusCode != 200) {
      print('Error al actualizar estado del pedido: ${resp.body}');
      return false;
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    return body['success'] == true;
  }

  /// Finaliza un pedido (versión alternativa)
  static Future<bool> finalizarPedido(String pedidoCodigo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    final uri = Uri.parse('${Config.apiUrl}/pedidos/finalizar/$pedidoCodigo');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode != 200) {
      debugPrint('Error al finalizar pedido: ${resp.statusCode} ${resp.body}');
      return false;
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    return body['success'] == true;
  }
}
