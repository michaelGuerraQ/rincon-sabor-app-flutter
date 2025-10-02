import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';

enum EstadoPedido {
  pendiente('Pendiente', 0xFFFF9800),
  cancelado('Cancelado', 0xFF2196F3),
  listo('Listo', 0xFF4CAF50),
  servido('Servido', 0xFF9E9E9E);

  const EstadoPedido(this.label, this.colorValue);
  final String label;
  final int colorValue;

  /// Convierte el estado del pedido a un enum basado en una cadena
  /// de texto. Si no coincide con ninguno, retorna `pendiente` por defecto.
  static EstadoPedido fromString(String estado) {
    // Normaliza la cadena a minúsculas para evitar problemas de coincidencia
    final normalizedEstado = estado.trim().toLowerCase();
    switch (normalizedEstado) {
      case 'pendiente':
        return EstadoPedido.pendiente;
      case 'cancelado':
        return EstadoPedido.cancelado;
      case 'listo':
        return EstadoPedido.listo;
      case 'servido':
        return EstadoPedido.servido;
      default:
        return EstadoPedido.pendiente;
    }
  }
}

class Pedido {
  final String pedidoCodigo;
  final DateTime pedidoFechaHora;
  final double pedidoTotal;
  String pedidoEstado;
  final String mesaCodigo;
  final String mesaNumero;
  final List<DetallePedido> detalles;

  Pedido({
    required this.pedidoCodigo,
    required this.pedidoFechaHora,
    required this.pedidoTotal,
    required this.pedidoEstado,
    required this.mesaCodigo,
    required this.mesaNumero,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final raw = (json['PedidoFechaHora'] as String).replaceFirst('Z', '');
    return Pedido(
      pedidoCodigo: json['PedidoCodigo'] ?? '',
      pedidoFechaHora: DateTime.parse(raw),
      pedidoTotal: (json['PedidoTotal'] ?? 0).toDouble(),
      pedidoEstado: json['PedidoEstado'] ?? '',
      mesaCodigo: json['MesaCodigo'] ?? '',
      mesaNumero: json['MesaNumero']?.toString() ?? '',
      detalles:
          (json['Detalles'] as List<dynamic>?)
              ?.map((detalle) => DetallePedido.fromJson(detalle))
              .toList() ??
          [],
    );
  }
  // Convertir el estado del pedido a un enum+
  /// esto representa el estado del pedido como un enum
  /// basado en la cadena de texto del estado del pedido.
  /// el timeAgo es una función que calcula el tiempo transcurrido
  /// desde que se creó el pedido, devolviendo un string
  EstadoPedido get estadoEnum => EstadoPedido.fromString(pedidoEstado);
  String get timeAgo {
    final now = DateTime.now();
    final difference = DateTime.now().difference(pedidoFechaHora);

    // DEBUG: muestra los valores usados en el cálculo
    print('DEBUG timeAgo → pedidoFechaHora: $pedidoFechaHora, now: $now, diferencia: $difference');

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
  }

  int get totalItems {
    return detalles.fold(0, (sum, detalle) => sum + detalle.cantidad);
  }

  // Verifica si todos los detalles están listos
  bool get todosDetallesListos {
    return detalles.isNotEmpty &&
        detalles.every((detalle) => detalle.estado.toLowerCase() == 'listo');
  }

  // Obtiene el progreso del pedido (porcentaje de detalles listos)
  double get progresoPedido {
    if (detalles.isEmpty) return 0.0;
    final detallesListos =
        detalles.where((d) => d.estado.toLowerCase() == 'listo').length;
    return detallesListos / detalles.length;
  }
}
