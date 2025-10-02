class WeeklyGain {
  final String semana;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double totalGanancia;

  WeeklyGain({
    required this.semana,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalGanancia,
  });

  factory WeeklyGain.fromJson(Map<String, dynamic> json) {
    return WeeklyGain(
      semana: json['Semana'] as String,
      fechaInicio: DateTime.parse(json['FechaInicioSemana'] as String),
      fechaFin: DateTime.parse(json['FechaFinSemana'] as String),
      totalGanancia: (json['TotalGanancia'] as num).toDouble(),
    );
  }
}


class WeeklyGainByMonth {
  final int semanaDelMes;
  final double ganancias;
  final int pedidos;

  WeeklyGainByMonth({
    required this.semanaDelMes,
    required this.ganancias,
    required this.pedidos,
  });

  factory WeeklyGainByMonth.fromJson(Map<String, dynamic> json) {
    return WeeklyGainByMonth(
      semanaDelMes: json['SemanaDelMes'] as int,
      ganancias: (json['Ganancias'] as num).toDouble(),
      pedidos: json['Pedidos'] as int,
    );
  }
}


class MonthlyGain {
  final int mes;
  final double ganancias;
  final int pedidos;

  MonthlyGain({
    required this.mes,
    required this.ganancias,
    required this.pedidos,
  });

  factory MonthlyGain.fromJson(Map<String, dynamic> json) {
    return MonthlyGain(
      mes: json['Mes'] as int,
      ganancias: (json['Ganancias'] as num).toDouble(),
      pedidos: json['Pedidos'] as int,
    );
  }
}

class PedidoHoy {
  final String pedidoCodigo;
  final List<PedidoDetalle> detalles;

  PedidoHoy({
    required this.pedidoCodigo,
    required this.detalles,
  });

  factory PedidoHoy.fromJson(Map<String, dynamic> json) {
    return PedidoHoy(
      pedidoCodigo: json['PedidoCodigo'] as String,
      detalles: (json['Detalles'] as List<dynamic>)
          .map((item) => PedidoDetalle.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PedidoDetalle {
  final String detallePedidoCodigo;
  final num detallePedidoSubtotal;

  PedidoDetalle({
    required this.detallePedidoCodigo,
    required this.detallePedidoSubtotal,
  });

  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    return PedidoDetalle(
      detallePedidoCodigo: json['detallePedidoCodigo'] as String,
      detallePedidoSubtotal: json['detallePedidoSubtotal'] as num,
    );
  }
}

class VentasHoy {
  final String fecha;
  final double totalVentas;

  VentasHoy({
    required this.fecha,
    required this.totalVentas,
  });

  factory VentasHoy.fromJson(Map<String, dynamic> json) {
    return VentasHoy(
      fecha: json['fecha'] as String,
      totalVentas: (json['totalVentas'] as num).toDouble(),
    );
  }
}

class MesasDisponibles {
  final String summary;
  final List<Mesa> mesas;

  MesasDisponibles({required this.summary, required this.mesas});

  factory MesasDisponibles.fromJson(Map<String, dynamic> json) {
    return MesasDisponibles(
      summary: json['data'] as String,
      mesas: (json['mesas'] as List<dynamic>)
          .map((e) => Mesa.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Mesa {
  final String mesaCodigo;
  final String mesaEstado;

  Mesa({required this.mesaCodigo, required this.mesaEstado});

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      mesaCodigo: json['MesaCodigo'] as String,
      mesaEstado: json['MesaEstado'] as String,
    );
  }
}

class GananciasMesActual {
  final int anio;
  final int mes;
  final double totalGanancias;
  final int totalPedidos;
  final List<dynamic> detalles; // Ajusta el tipo según tus necesidades

  GananciasMesActual({
    required this.anio,
    required this.mes,
    required this.totalGanancias,
    required this.totalPedidos,
    required this.detalles,
  });

  factory GananciasMesActual.fromJson(Map<String, dynamic> json) {
    return GananciasMesActual(
      anio: json['anio'] as int,
      mes: json['mes'] as int,
      totalGanancias: (json['totalGanancias'] as num).toDouble(),
      totalPedidos: json['totalPedidos'] as int,
      detalles: json['detalles'] as List<dynamic>,
    );
  }
}