import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/widgets/categoria_card.dart';

class CategoriaListView extends StatelessWidget {
  final List<Categoria> categorias;
  final Future<bool> Function(Categoria) onActualizar;
  final Future<bool> Function(Categoria) onEliminar;

  const CategoriaListView({
    super.key,
    required this.categorias,
    required this.onActualizar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return CategoriaCard(
          categoria: categoria,
          onActualizar: onActualizar,
          onEliminar: onEliminar,
        );
      },
    );
  }
}
