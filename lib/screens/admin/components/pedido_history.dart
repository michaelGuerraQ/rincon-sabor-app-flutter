import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';

class PedidoHistory {
  final String id;
  final String numeroPedido;
  final DateTime fecha;
  final String mesa;
  final List<ItemPedido> items;
  final String estado;
  final double total;

  PedidoHistory({
    required this.id,
    required this.numeroPedido,
    required this.fecha,
    required this.mesa,
    required this.items,
    required this.estado,
    required this.total,
  });

  factory PedidoHistory.fromPedido(Pedido pedido) {
    return PedidoHistory(
      id: pedido.pedidoCodigo,
      numeroPedido: pedido.pedidoCodigo,
      fecha: pedido.pedidoFechaHora,
      mesa: pedido.mesaNumero,
      items: pedido.detalles.map((detalle) => ItemPedido.fromDetalle(detalle)).toList(),
      estado: pedido.pedidoEstado,
      total: pedido.pedidoTotal,
    );
  }

  static Future<List<PedidoHistory>> loadHistorial({
    int page = 1,
    int limit = 10,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // print('No user logged in');
      return [];
    }
    final token = await user.getIdToken();

    // Use yyyy-MM-dd format (set to true for ISO 8601 or UTC testing)
    // const useIso8601 = false;
    // const useUtc = false; // Set to true to send dates in UTC

    // Convert dates to the appropriate format
    String? fechaDesdeString;
    String? fechaHastaString;

    DateTime? adjustedFechaDesde = fechaDesde;
    DateTime? adjustedFechaHasta = fechaHasta;


    if (adjustedFechaDesde != null) {
      fechaDesdeString = DateFormat('yyyy-MM-dd').format(adjustedFechaDesde);
    }

    if (adjustedFechaHasta != null) {
      // Ensure fechaHasta includes the entire day for yyyy-MM-dd
      final endOfDay = DateTime(
        adjustedFechaHasta.year,
        adjustedFechaHasta.month,
        adjustedFechaHasta.day,
        23, 59, 59,
      );
      fechaHastaString = DateFormat('yyyy-MM-dd').format(endOfDay);
    }

    // Build the URL with date parameters
    final queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (fechaDesdeString != null) 'fechaDesde': fechaDesdeString,
      if (fechaHastaString != null) 'fechaHasta': fechaHastaString,
    };
    final uri = Uri.parse('${Config.apiUrl}/pedidos/todos').replace(queryParameters: queryParameters);

    // // Debugging: Log the request details
    // print('API Request: $uri');
    // print('Token: Bearer $token');
    // print('FechaDesde sent: $fechaDesdeString');
    // print('FechaHasta sent: $fechaHastaString');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    // Debugging: Log the response details
    // print('API Response Status: ${resp.statusCode}');
    // print('API Response Body: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Error al obtener historial de pedidos: ${resp.statusCode}');
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Respuesta inválida');
    }

    final data = body['data'] as List;
    final pedidos = data.map((json) => PedidoHistory.fromPedido(Pedido.fromJson(json))).toList();

    // Log the dates of returned pedidos
    // // print('Parsed ${pedidos.length} pedidos: ${pedidos.map((p) => "${p.numeroPedido}: ${p.fecha.toString()}").toList()}');

    return pedidos;
  }
}

class ItemPedido {
  final String nombre;
  final int cantidad;
  final double precio;

  ItemPedido({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  factory ItemPedido.fromDetalle(DetallePedido detalle) {
    return ItemPedido(
      nombre: detalle.producto.platos,
      cantidad: detalle.cantidad,
      precio: detalle.producto.precio,
    );
  }
}