import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rincon_sabor_flutter/config.dart';
import 'package:rincon_sabor_flutter/core/models/weekLyGain_model.dart';

class GraficodataService {
  static Future<List<WeeklyGain>> fetchGananciasSemanales() async {
    final uri = Uri.parse('${Config.apiUrl}/dataGraficos/gananciasSemanales');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener ganancias semanales: ${resp.statusCode}',
      );
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    final List<dynamic> lista = body['data'];
    return lista
        .map((e) => WeeklyGain.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<WeeklyGainByMonth>> fetchGananciasSemanalesPorMes({
    required int anio,
    required int mes,
  }) async {
    final uri = Uri.parse(
      '${Config.apiUrl}/dataGraficos/gananciasSemanalesPorMes?anio=$anio&mes=$mes',
    );

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener ganancias semanales por mes: ${resp.statusCode}',
      );
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    final List<dynamic> lista = body['data'];
    return lista
        .map((e) => WeeklyGainByMonth.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<MonthlyGain>> fetchGananciasMensuales({
    required int anio,
  }) async {
    final uri = Uri.parse(
      '${Config.apiUrl}/dataGraficos/gananciasMensuales?anio=$anio',
    );
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener ganancias mensuales: ${resp.statusCode}',
      );
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    final List<dynamic> lista = body['data'];
    return lista
        .map((e) => MonthlyGain.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<PedidoHoy>> fetchPedidosHoy() async {
    final uri = Uri.parse('${Config.apiUrl}/dataGraficos/pedidosHoy');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener pedidos de hoy: ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    final List<dynamic> lista = body['data'];
    return lista
        .map((e) => PedidoHoy.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<VentasHoy> fetchVentasHoy() async {
    final uri = Uri.parse('${Config.apiUrl}/dataGraficos/ventasHoy');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener ventas de hoy: ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    return VentasHoy.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<MesasDisponibles> fetchMesasDisponibles() async {
    final uri = Uri.parse('${Config.apiUrl}/dataGraficos/disponibles');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener mesas disponibles: ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    return MesasDisponibles.fromJson(body);
  }

  static Future<GananciasMesActual> fetchGananciasMesActual() async {
    final uri = Uri.parse('${Config.apiUrl}/dataGraficos/gananciasMesActual');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener ganancias del mes actual: ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Respuesta inesperada del servidor');
    }

    return GananciasMesActual.fromJson(body['data'] as Map<String, dynamic>);
  }
}
