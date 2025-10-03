import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesData {
  final String label;
  final double value;
  SalesData(this.label, this.value);
}

class SalesChart extends StatefulWidget {
  final List<SalesData> data;

  const SalesChart({super.key, required this.data});

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _disposed = true;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN: Verificar disposed antes de render
    if (_disposed) return const SizedBox.shrink();

    return SfCartesianChart(
      title: ChartTitle(text: 'Ultimas ventas del mes'),
      legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Ventas S/.')),
      series: <CartesianSeries>[
        LineSeries<SalesData, String>(
          dataSource: widget.data,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          // CORRECCIÓN: Deshabilitar animaciones problemáticas
          animationDuration: 0,
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
class EarningsChart extends StatefulWidget {
  final List<EarningsData> data;

  const EarningsChart({super.key, required this.data});

  @override
  State<EarningsChart> createState() => _EarningsChartState();
}

class _EarningsChartState extends State<EarningsChart> {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    return SfCircularChart(
      title: ChartTitle(text: 'Ganancias de Enero-Junio'),
      legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      series: <CircularSeries>[
        PieSeries<EarningsData, String>(
          dataSource: widget.data,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          // CORRECCIÓN: Deshabilitar animaciones
          animationDuration: 0,
        )
      ],
    );
  }
}