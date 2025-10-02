import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:rincon_sabor_flutter/core/services/clima_service.dart';

Future<Map<String, double>> predecirVentasManana() async {
  final historial = await obtenerHistorial();

  if (historial.isEmpty) {
    return {}; // Sin datos, sin predicciones
  }

  final fechas =
      historial
          .map((e) => DateTime.parse(e['PedidoFechaHora']).toLocal())
          .toList();

  final inicio = fechas.reduce((a, b) => a.isBefore(b) ? a : b);
  final fin = fechas.reduce((a, b) => a.isAfter(b) ? a : b);

  final temperaturasHistoricas = await obtenerTemperaturasHistoricas(
    inicio,
    fin,
  );

  final temperatura = await obtenerTemperaturaManana();
  final diaManana = DateTime.now().add(Duration(days: 1)).weekday % 7;

  print('Temperatura estimada para mañana: $temperatura');
  print('Día de la semana (mañana): $diaManana');
  print('Ventas históricas obtenidas: ${historial.length} registros');

  // 🔧 Dataset sin la columna 'nombre' para evitar problemas de dimensiones
  final dataset = <List<dynamic>>[
    ['temperatura', 'dia', 'cantidad'],
  ];

  int registrosValidos = 0;
  int registrosDescartados = 0;

  for (var e in historial) {
    final fecha = DateTime.parse(e['PedidoFechaHora']).toLocal();
    final dia = fecha.weekday % 7;
    final plato = e['MenuPlatos'];
    final cantidad = e['CantidadVendida'];

    // 🔧 Usar formato ISO consistente con Open-Meteo
    final fechaStr = fecha.toIso8601String().split('T')[0];

    // 🔧 Solo usar temperaturas reales (no fallbacks)
    final temp = temperaturasHistoricas[fechaStr];

    if (temp != null) {
      dataset.add([temp, dia, cantidad]);
      registrosValidos++;
      print(
        'Registro: temperatura=$temp, dia=$dia, plato=$plato, cantidad=$cantidad',
      );
    } else {
      registrosDescartados++;
      print('⚠️ Descartando registro sin temperatura para fecha $fechaStr');
    }
  }

  print(
    '📊 Registros válidos: $registrosValidos, Descartados: $registrosDescartados',
  );

  if (registrosValidos == 0) {
    print('❌ No hay registros válidos para hacer predicciones');
    return {};
  }

  // 🔧 Agrupar datos por plato manualmente
  final Map<String, List<Map<String, dynamic>>> datosPorPlato = {};

  for (var e in historial) {
    final fecha = DateTime.parse(e['PedidoFechaHora']).toLocal();
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final temp = temperaturasHistoricas[fechaStr];

    if (temp != null) {
      final plato = e['MenuPlatos'];
      final dia = fecha.weekday % 7;
      final cantidad = e['CantidadVendida'];

      if (!datosPorPlato.containsKey(plato)) {
        datosPorPlato[plato] = [];
      }

      datosPorPlato[plato]!.add({
        'temperatura': temp,
        'dia': dia,
        'cantidad': cantidad,
      });
    }
  }

  final predicciones = <String, double>{};
  print('Platos únicos encontrados: ${datosPorPlato.length}');

  for (var entry in datosPorPlato.entries) {
    final plato = entry.key;
    final datos = entry.value;

    if (datos.length < 2) {
      print('Plato "$plato" tiene pocos datos (${datos.length}), se omite.');
      continue;
    }

    try {
      // 🔧 Crear DataFrame solo con datos numéricos
      final filasDatos =
          datos
              .map(
                (d) => [
                  d['temperatura'],
                  d['dia'],
                  // d['cantidad']
                ],
              )
              .toList();

      final df = DataFrame([
        ['temperatura', 'dia', 'cantidad'], // Headers completos
        ...datos.map(
          (d) => [
            d['temperatura'],
            d['dia'],
            d['cantidad'], // Datos completos
          ],
        ),
      ]);

      final model = LinearRegressor(df, 'cantidad');

      // 🔧 Crear input de predicción con la misma estructura
      final testInput = DataFrame([
        ['temperatura', 'dia'], // Solo features
        [temperatura, diaManana], // Solo valores de entrada
      ]);

      final resultado = model.predict(testInput);
      final cantidadPredecida = resultado.rows.first.first.toDouble();

      // 🔧 Redondear y aplicar límites realistas
      final cantidadFinal = (cantidadPredecida.clamp(0, 50)).round().toDouble();

      print('🔮 Predicción plato "$plato": $cantidadFinal');
      predicciones[plato] = cantidadFinal;
    } catch (e) {
      print('❌ Error al predecir "$plato": $e');
    }
  }

  if (predicciones.isEmpty) {
    print('❌ No se pudieron generar predicciones');
  }

  return predicciones;
}
