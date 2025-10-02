// create table Recetas
// (
// 	RecetaCodigo		nchar(10),
// 	RecetaMenuCodigo	nchar(10) unique, --- un menu solo deberiatener una receta.
// 	RecetaEstado		nchar(1) default 'A'
// 	constraint RecetaCodigoPk primary key (RecetaCodigo),
// 	constraint RecetaMenuFk foreign key (RecetaMenuCodigo) references Pedidos.Menu (MenuCodigo),
// 	constraint RecetaEstadoCk check(RecetaEstado = 'A'  or RecetaEstado = 'I')
// )
// go


class Receta {
  final String codigo;
  final String menuCodigo;
  final String estado;

  Receta({
    required this.codigo,
    required this.menuCodigo,
    this.estado = 'A', // por defecto activo
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      codigo: json['RecetaCodigo'],
      menuCodigo: json['RecetaMenuCodigo'],
      estado: json['RecetaEstado'] ?? 'A', // si no viene, por defecto activo
    );
  }
}