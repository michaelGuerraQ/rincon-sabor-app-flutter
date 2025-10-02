class DetalleReceta {
  final String recetaDetalleCodigo;
  final double recetaDetalleCantidadporPlato;
  final String insumoCodigo;
  final String insumoNombre;
  final String insumoUnidadMedida;
  final double insumoStockActual;
  final double insumoCompraUnidad;

  DetalleReceta({
    required this.recetaDetalleCodigo,
    required this.recetaDetalleCantidadporPlato,
    required this.insumoCodigo,
    required this.insumoNombre,
    required this.insumoUnidadMedida,
    required this.insumoStockActual,
    required this.insumoCompraUnidad,
  });

  factory DetalleReceta.fromJson(Map<String, dynamic> json) => DetalleReceta(
    recetaDetalleCodigo: json['RecetaDetalleCodigo'],
    recetaDetalleCantidadporPlato: (json['RecetaDetalleCantidadporPlato'] ?? 0).toDouble(),
    insumoCodigo: json['InsumoCodigo'],
    insumoNombre: json['InsumoNombre'],
    insumoUnidadMedida: json['InsumoUnidadMedida'],
    insumoStockActual: (json['InsumoStockActual'] ?? 0).toDouble(),
    insumoCompraUnidad: (json['InsumoCompraUnidad'] ?? 0).toDouble(),
  );
}

class MenuDetallado {
  final String menuCodigo;
  final String menuPlatos;
  final String menuDescripcion;
  final double menuPrecio;
  final String menuEstado;
  final String? menuImageUrl;
  final String menuEsPreparado;
  final String menuCategoriaCodigo;
  final String? insumoDirectoCodigo;
  final String? insumoDirectoNombre;
  final List<DetalleReceta> detallesReceta;

  MenuDetallado({
    required this.menuCodigo,
    required this.menuPlatos,
    required this.menuDescripcion,
    required this.menuPrecio,
    required this.menuEstado,
    required this.menuImageUrl,
    required this.menuEsPreparado,
    required this.menuCategoriaCodigo,
    required this.insumoDirectoCodigo,
    required this.insumoDirectoNombre,
    required this.detallesReceta,
  });

  factory MenuDetallado.fromJson(Map<String, dynamic> json) => MenuDetallado(
    menuCodigo: json['MenuCodigo'],
    menuPlatos: json['MenuPlatos'],
    menuDescripcion: json['MenuDescripcion'],
    menuPrecio: (json['MenuPrecio'] ?? 0).toDouble(),
    menuEstado: json['MenuEstado'],
    menuImageUrl: json['MenuImageUrl'],
    menuEsPreparado: json['MenuEsPreparado'],
    menuCategoriaCodigo: json['MenuCategoriaCodigo'],
    insumoDirectoCodigo: json['InsumoDirectoCodigo'],
    insumoDirectoNombre: json['InsumoDirectoNombre'],
    detallesReceta: (json['DetallesReceta'] as List<dynamic>?)
        ?.map((e) => DetalleReceta.fromJson(e))
        .toList() ?? [],
  );
}


