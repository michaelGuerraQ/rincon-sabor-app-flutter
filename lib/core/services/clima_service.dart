import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rincon_sabor_flutter/config.dart';

/// 🔹 Obtiene la temperatura máxima para mañana desde Open-Meteo
Future<double> obtenerTemperaturaManana() async {
  try {
    // print('🌡️ Obteniendo temperatura para mañana...');
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=-8.111&longitude=-79.028'
      '&daily=temperature_2m_max&timezone=America/Lima',
    );

    // print('🌐 URL: $uri');
    final res = await http.get(uri);
    // print('📡 Status Code: ${res.statusCode}');

    if (res.statusCode == 200) {
      // print('✅ Respuesta exitosa: ${res.body.substring(0, 200)}...');
      final data = jsonDecode(res.body);
      final tempValue = data['daily']['temperature_2m_max'][1];
      final temperatura = tempValue?.toDouble() ?? 22.0; // usar 22.0 si es null
      // print('🌡️ Temperatura mañana: $temperatura°C');
      return temperatura;
    } else {
      // print('❌ Error HTTP: ${res.statusCode} - ${res.body}');
      throw Exception(
        'Error al obtener temperatura de mañana: ${res.statusCode}',
      );
    }
  } catch (e) {
    // print('💥 Excepción en obtenerTemperaturaManana: $e');
    rethrow;
  }
}

/// 🔹 Obtiene temperaturas históricas entre dos fechas
Future<Map<String, double>> obtenerTemperaturasHistoricas(
  DateTime inicio,
  DateTime fin,
) async {
  try {
    // print('📊 Obteniendo temperaturas históricas desde $inicio hasta $fin');
    
    // 🔧 Ajustar la fecha final para evitar fechas muy recientes sin datos
    final ahora = DateTime.now();
    final finSeguro = fin.isAfter(ahora.subtract(Duration(days: 2))) 
        ? ahora.subtract(Duration(days: 2)) 
        : fin;
    
    final url = Uri.parse(
      'https://archive-api.open-meteo.com/v1/archive'
      '?latitude=-8.111&longitude=-79.028'
      '&start_date=${inicio.toIso8601String().split("T")[0]}'
      '&end_date=${finSeguro.toIso8601String().split("T")[0]}'
      '&daily=temperature_2m_max&timezone=America/Lima',
    );

    // print('🌐 URL histórica: $url');
    final res = await http.get(url);
    // print('📡 Status Code histórico: ${res.statusCode}');

    if (res.statusCode == 200) {
      // print('✅ Respuesta histórica exitosa: ${res.body.substring(0, 200)}...');
      final data = jsonDecode(res.body);
      final List fechas = data['daily']['time'];
      final List temps = data['daily']['temperature_2m_max'];

      // print('📅 Fechas obtenidas: ${fechas.length}');
      // print('🌡️ Temperaturas obtenidas: ${temps.length}');

      final Map<String, double> mapa = {};
      for (int i = 0; i < fechas.length; i++) {
        final temp = temps[i];
        if (temp != null) {
          mapa[fechas[i]] = temp.toDouble();
        } else {
          // Usar temperatura promedio de días válidos en lugar de saltarse
          final tempPromedio = _calcularTemperaturaPromedio(temps);
          mapa[fechas[i]] = tempPromedio;
          // print('🌡️ Usando temperatura promedio $tempPromedio para ${fechas[i]}');
        }
      }
      // print('🗺️ Mapa creado con ${mapa.length} entradas');
      return mapa;
    } else {
      // print('❌ Error HTTP histórico: ${res.statusCode} - ${res.body}');
      throw Exception(
        'Error al obtener temperaturas históricas: ${res.statusCode}',
      );
    }
  } catch (e) {
    // print('💥 Excepción en obtenerTemperaturasHistoricas: $e');
    rethrow;
  }
}

/// 🔹 Calcula la temperatura promedio de valores válidos
double _calcularTemperaturaPromedio(List temps) {
  final valoresValidos = temps.where((t) => t != null).cast<double>();
  return valoresValidos.isEmpty 
      ? 22.0 // temperatura por defecto para Trujillo
      : valoresValidos.reduce((a, b) => a + b) / valoresValidos.length;
}

/// 🔹 Obtiene historial de ventas desde tu backend
Future<List<Map<String, dynamic>>> obtenerHistorial() async {
  try {
    // print('🛒 Obteniendo historial de ventas...');
    final uri = Uri.parse('${Config.apiUrl}/predicciones/ventas-historicas');
    // print('🌐 URL backend: $uri');

    final res = await http.get(uri);
    // print('📡 Status Code backend: ${res.statusCode}');

    if (res.statusCode == 200) {
      // print('✅ Respuesta backend exitosa');
      final List data = jsonDecode(res.body);
      // print('📊 Registros de historial obtenidos: ${data.length}');
      
      return data.cast<Map<String, dynamic>>();
    } else {
      // print('❌ Error HTTP backend: ${res.statusCode} - ${res.body}');
      throw Exception(
        'Error al obtener historial de ventas: ${res.statusCode}',
      );
    }
  } catch (e) {
    // print('💥 Excepción en obtenerHistorial: $e');
    rethrow;
  }
}