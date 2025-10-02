import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesData {
  final String label;
  final double value;
  SalesData(this.label, this.value);
}

class SalesChart extends StatelessWidget {
  final List<SalesData> data;

  const SalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Ultimas ventas del mes'),
      legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(title: AxisTitle(
        text: 'Ventas (S/.)'),
      ),
      series: <CartesianSeries>[
        LineSeries<SalesData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}

/// Datos para el grafico de ganancias
class EarningsData {
  final String label;
  final double value;
  EarningsData(this.label, this.value);
}

/// Gráfico circular de ganancias
class EarningsChart extends StatelessWidget {
  final List<EarningsData> data;
  const EarningsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(text: 'Ganancias de Enero-Junio'),
      legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      series: <CircularSeries>[
        PieSeries<EarningsData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}
