import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/services/categoria_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/widgets/categoria_listview.dart';

class CategoriasListScreen extends StatefulWidget {
  const CategoriasListScreen({super.key});

  @override
  _CategoriasListScreenState createState() => _CategoriasListScreenState();
}

class _CategoriasListScreenState extends State<CategoriasListScreen> {
  List<Categoria> _cats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _cats = await CategoriaService.obtenerCategorias();
    setState(() => _loading = false);
  }

  Future<bool?> _showAgregarCategoriaDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('dialogAgregarCategoria'),
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Nueva Categoría',
              key: const Key('tituloDialogAgregar'),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('txtNombreCategoria'),
              controller: nombreCtrl,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('txtDescripcionCategoria'),
              controller: descCtrl,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('btnCancelarAgregar'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            key: const Key('btnGuardarCategoria'),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final descripcion = descCtrl.text.trim();

              if (nombre.isEmpty || descripcion.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Todos los campos son obligatorios'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              setState(() => _loading = true);

              try {
                final ok = await CategoriaService.agregarCategoria(
                  categoriaNombre: nombre,
                  categoriaDescripcion: descripcion,
                );

                if (ok) {
                  Navigator.pop(ctx, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Categoría agregada exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Error al agregar la categoría'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ocurrió un error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } finally {
                setState(() => _loading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: const Key('screenCategorias'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _loading
          ? const Center(
        key: Key('loadingCategorias'),
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        key: const Key('refreshCategorias'),
        onRefresh: _load,
        child: CategoriaListView(
          key: const Key('listViewCategorias'),
          categorias: _cats,
          onActualizar: (cat) => _actualizarCategoria(cat),
          onEliminar: (cat) => _eliminarCategoria(cat),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('btnAgregarCategoria'),
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final created = await _showAgregarCategoriaDialog();
          if (created == true) await _load();
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
