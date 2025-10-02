import 'package:rincon_sabor_flutter/core/models/menu.dart';

enum EstadoDetalle {
  pendiente('Pendiente', 0xFFFF9800),
  preparando('Preparando', 0xFF2196F3),
  listo('Listo', 0xFF4CAF50),
  cancelado('Cancelado', 0xFFF44336),
  servido('Servido', 0xFF9E9E9E); 

  const EstadoDetalle(this.label, this.colorValue);
  final String label;
  final int colorValue;

  static EstadoDetalle fromString(String s) {
    switch (s.trim().toLowerCase()) {
      case 'pendiente':
        return EstadoDetalle.pendiente;
      case 'preparando':
        return EstadoDetalle.preparando;
      case 'listo':
        return EstadoDetalle.listo;
      case 'cancelado':
        return EstadoDetalle.cancelado;
      default:
        return EstadoDetalle.pendiente;
    }
  }
}

class DetallePedido {
  final String detallePedidoCodigo;
  final int cantidad;
  String estado;
  final String notas;
  final Menu producto;

  DetallePedido({
    required this.detallePedidoCodigo,
    required this.cantidad,
    required this.estado,
    required this.notas,
    required this.producto,
  });

  // ¿Está listo?
  bool get isListo => estadoEnum == EstadoDetalle.listo;
  bool get isServido => estadoEnum == EstadoDetalle.servido;
  // calculado
  double get subtotal => producto.precio * cantidad;

  
  EstadoDetalle get estadoEnum => EstadoDetalle.fromString(estado);

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      detallePedidoCodigo: json['DetallePedidoCodigo']?.toString() ?? '',
      cantidad: (json['Cantidad'] as num?)?.toInt() ?? 0,
      estado: json['Estado']?.toString() ?? '',
      notas: json['Notas']?.toString() ?? '',
      producto: Menu.fromJson(json['Producto'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DetallePedidoCodigo': detallePedidoCodigo,
      'Cantidad': cantidad,
      'Estado': estado,
      'Notas': notas,
      // solo mando el código del menú si así lo espera tu API:
      'MenuCodigo': producto.codigo,
      'Subtotal': subtotal,
    };
  }

   bool get esPreparado => producto.esPreparado == 'A';

  /// Mapa para crear un nuevo detalle de pedido.
  /// Asume que la API espera un mapa con los campos necesarios.
  Map<String, dynamic> toCreationMap() {
    return {
      'detallePedidoSubtotal': subtotal,
      'detallePedidoCantidad': cantidad,
      'detallePedidoEstado': estado,
      'detallePedidoNotas': notas,
      'detallePedidoMenuCodigo': producto.codigo,
      /// si tu API espera un campo específico para indicar si es preparado:
      'MenuEsPreparado':producto.esPreparado,
    };
  }


  // Copia modificable
  DetallePedido copyWith({
    String? detallePedidoCodigo,
    int? cantidad,
    String? estado,
    String? notas,
    Menu? producto,
  }) {
    return DetallePedido(
      detallePedidoCodigo: detallePedidoCodigo ?? this.detallePedidoCodigo,
      cantidad: cantidad ?? this.cantidad,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      producto: producto ?? this.producto,
    );
  }
}