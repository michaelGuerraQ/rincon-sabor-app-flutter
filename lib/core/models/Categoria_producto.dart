//// filepath: lib/core/models/Categoria_producto.dart
class Categoria {
  final String codigo;
  String nombre;
  String descripcion;
  final String estado;

  Categoria({
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.estado,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      codigo:      json['CategoriaCodigo']    as String,
      nombre:      json['CategoriaNombre']    as String,
      descripcion: json['CategoriaDescripcion'] as String,
      estado:      json['CategoriaEstado']    as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'CategoriaCodigo': codigo,
    'CategoriaNombre': nombre,
    'CategoriaDescripcion': descripcion,
    'CategoriaEstado': estado,
  };
}