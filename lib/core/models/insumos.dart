//// filepath: lib/core/models/insumos.dart
class Insumos {
  final String? codigo;
  final String? nombre;
  final String? unidadMedida;
  final double? stockActual;
  final double? compraUnidad;
  final String? estado;

  Insumos({
    this.codigo,
    this.nombre,
    this.unidadMedida,
    this.stockActual,
    this.compraUnidad,
    this.estado,
  });

  factory Insumos.fromJson(Map<String, dynamic> json) {
    return Insumos(
      codigo:       json['InsumoCodigo']        as String?,
      nombre:       json['InsumoNombre']        as String?,
      unidadMedida: json['InsumoUnidadMedida']  as String?,
      stockActual:  (json['InsumoStockActual']   as num?)?.toDouble(),
      compraUnidad: (json['InsumoCompraUnidad']  as num?)?.toDouble(),
      estado:       json['InsumoEstado']        as String?,
    );
  }
}