class MenuRequest {
  final String platos;
  final String? descripcion;
  final double precio;
  final String categoriaCodigo;
  final String esPreparado; // 'A' o 'I'
  final List<RecetaDetalleRequest>? receta; // sólo si esPreparado=='A'
  final InsumoRequest? insumo;              // sólo si esPreparado=='I'

  MenuRequest({
    required this.platos,
    this.descripcion,
    required this.precio,
    required this.categoriaCodigo,
    required this.esPreparado,
    this.receta,
    this.insumo,
  });

  Map<String, dynamic> toJson() {
    final m = <String,dynamic>{
      'MenuPlatos': platos,
      'MenuPrecio': precio,
      'MenuCategoriaCodigo': categoriaCodigo,
      'MenuEsPreparado': esPreparado,
    };
    if (descripcion != null) m['MenuDescripcion'] = descripcion;
    if (esPreparado == 'A' && receta != null) {
      m['DetallesReceta'] = receta!.map((d) => d.toJson()).toList();
    }
    if (esPreparado == 'I' && insumo != null) {
      m.addAll(insumo!.toJson());
    }
    return m;
  }
}

/// Cada línea de receta
class RecetaDetalleRequest {
  final String insumoCodigo;
  final double cantidadPorPlato;
  RecetaDetalleRequest({
    required this.insumoCodigo,
    required this.cantidadPorPlato,
  });
  Map<String, dynamic> toJson() => {
        'insumoCodigo': insumoCodigo,
        'cantidad': cantidadPorPlato,
      };
}

/// Datos de un insumo nuevo (bebida, etc.)
class InsumoRequest {
  final String unidadMedida;
  final double stockActual;
  final double compraUnidad;
  InsumoRequest({
    required this.unidadMedida,
    required this.stockActual,
    required this.compraUnidad,
  });
  Map<String, dynamic> toJson() => {
        'InsumoUnidadMedida': unidadMedida,
        'InsumoStockActual': stockActual,
        'InsumoCompraUnidad': compraUnidad,
      };
}

class RecetaDetalle {
  final String insumoCodigo;
  final double cantidad;

  RecetaDetalle({required this.insumoCodigo, required this.cantidad});

  Map<String, dynamic> toJson() => {
    'insumoCodigo': insumoCodigo,
    'cantidad': cantidad,
  };
}

class MenuUpdateRequest {
  final String menuCodigo;
  final String menuPlatos;
  final String menuDescripcion;
  final double menuPrecio;
  final String menuEstado;
  final String? menuImageUrl;
  final String menuCategoriaCodigo;
  final String menuEsPreparado;
  final String? menuInsumoCodigo;
  final List<RecetaDetalle>? detallesReceta;

  MenuUpdateRequest({
    required this.menuCodigo,
    required this.menuPlatos,
    required this.menuDescripcion,
    required this.menuPrecio,
    required this.menuEstado,
    this.menuImageUrl,
    required this.menuCategoriaCodigo,
    required this.menuEsPreparado,
    this.menuInsumoCodigo,
    this.detallesReceta,
  });

  Map<String, dynamic> toJson() => {
    'MenuCodigo': menuCodigo,
    'MenuPlatos': menuPlatos,
    'MenuDescripcion': menuDescripcion,
    'MenuPrecio': menuPrecio,
    'MenuEstado': menuEstado,
    'MenuImageUrl': menuImageUrl,
    'MenuCategoriaCodigo': menuCategoriaCodigo,
    'MenuEsPreparado': menuEsPreparado,
    'MenuInsumoCodigo': menuInsumoCodigo,
    'DetallesReceta': detallesReceta?.map((e) => e.toJson()).toList()
  };
}
