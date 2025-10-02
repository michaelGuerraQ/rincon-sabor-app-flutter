import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';

class Menu {
  final String codigo;
  final String platos;
  final String descripcion;
  final double precio;
  final String estado;
  final String? imageUrl;
  final String esPreparado;
  final bool menuDisponible;
  final bool insumosFaltantes;
  final Insumos? insumo;
  final Categoria? categoria;

  Menu({
    required this.codigo,
    required this.platos,
    required this.descripcion,
    required this.precio,
    required this.estado,
    this.imageUrl,
    required this.esPreparado,
    required this.menuDisponible,
    required this.insumosFaltantes,
    this.insumo,
    this.categoria,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    // normalizamos bool/cadena
    bool parseBool(dynamic v) =>
        v is bool ? v : v?.toString().toLowerCase() == 'true';

    return Menu(
      codigo:            json['MenuCodigo']?.toString()        ?? '',
      platos:            json['MenuPlatos']?.toString()        ?? '',
      descripcion:       json['MenuDescripcion']?.toString()   ?? '',
      precio:            (json['MenuPrecio'] as num?)?.toDouble()?? 0.0,
      estado:            json['MenuEstado']?.toString()        ?? '',
      imageUrl:          json['MenuImageUrl']?.toString(),
      esPreparado:       json['MenuEsPreparado']?.toString()   ?? '',
      menuDisponible:    parseBool(json['MenuDisponible']),
      insumosFaltantes:  parseBool(json['InsumosFaltantes']),
      insumo: json['Insumo'] != null
          ? Insumos.fromJson(json['Insumo'] as Map<String, dynamic>)
          : null,
      categoria: json['Categoria'] != null
          ? Categoria.fromJson(json['Categoria'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isAvailable => menuDisponible && !insumosFaltantes;
}