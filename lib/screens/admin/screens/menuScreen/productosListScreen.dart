import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/models/menu.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/view_model/productos_list_view_model.dart';
import 'package:rincon_sabor_flutter/core/widgets/input_search.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/widgets/agregarMenu.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/widgets/producto_detalle_screen.dart';
import 'package:rincon_sabor_flutter/screens/mesero/components/category_header.dart';
import 'package:rincon_sabor_flutter/core/widgets/menu_listview.dart';

class ProductosListScreen extends StatefulWidget {
  const ProductosListScreen({super.key});

  @override
  State<ProductosListScreen> createState() => _ProductosListScreenState();
}

class _ProductosListScreenState extends State<ProductosListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCategoriaWidget(
    Categoria categoria,
    ProductosListViewModel viewModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool esVisible = viewModel.categoriasVisibles[categoria.nombre] ?? false;
    final filteredListForCat = viewModel.getProductosFiltrados(categoria);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha:0.3)
                    : Colors.grey.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryHeader(
            title: categoria.nombre,
            arrowId: 'arrow${categoria.codigo}',
            onArrowPressed:
                () => viewModel.toggleCategoriaVisibility(categoria.nombre),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                esVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
            ),
          ),
          if (esVisible)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MenuListView(
                menu: filteredListForCat,
                actionIcon:
                    (menu) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón Ver/Editar
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.visibility_rounded,
                              color: AppColors.info,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductoDetalleScreen(
                                        menuCodigo: menu.codigo,
                                        nombreProducto: menu.platos,
                                      ),
                                ),
                              );
                              if (result == true) {
                                // Recargar datos si hubo cambios
                                viewModel.cargarDatosIniciales();
                              }
                            },
                            tooltip: 'Ver detalles',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón Eliminar
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_rounded,
                              color: AppColors.error,
                            ),
                            onPressed:
                                () => _mostrarDialogoEliminar(menu, viewModel),
                            tooltip: 'Eliminar producto',
                          ),
                        ),
                      ],
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoEliminar(Menu menu, ProductosListViewModel viewModel) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '¿Eliminar menú?',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Eliminar el menú "${menu.platos}"?',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // CORRECCIÓN: Verificar mounted después del diálogo
    if (!mounted) return;

    if (confirmado == true) {
      final eliminado = await viewModel.eliminarProducto(menu.codigo);

      // CORRECCIÓN: Verificar mounted después de operación async
      if (!mounted) return;

      if (eliminado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Menú eliminado con éxito'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al eliminar el menú'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (context) => ProductosListViewModel(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<ProductosListViewModel>(
          builder: (context, viewModel, child) {
            return viewModel.isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF2D3748)
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDark
                                      ? Colors.black.withValues(alpha:0.3)
                                      : Colors.grey.withValues(alpha:0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cargando productos...',
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              isDark ? Colors.white70 : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(0xFF2D3748)
                                : AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withValues(alpha:0.2)
                                    : Colors.grey.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomSearchBar(
                        controller: _searchController,
                        hintText: 'Buscar platos...',
                        onChanged: (value) {
                          viewModel.updateSearchText(value);
                        },
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: viewModel.refresh,
                        color: AppColors.primary,
                        backgroundColor:
                            isDark
                                ? const Color(0xFF2D3748)
                                : AppColors.surface,
                        child:
                            viewModel.getCategoriasVisibles().isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(32),
                                        decoration: BoxDecoration(
                                          color:
                                              isDark
                                                  ? const Color(0xFF2D3748)
                                                  : AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  isDark
                                                      ? Colors.black
                                                          .withValues(alpha:0.3)
                                                      : Colors.grey.withValues(alpha:
                                                        0.1,
                                                      ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.search_off_rounded,
                                              size: 64,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                          .withValues(alpha:0.3)
                                                      : AppColors.textSecondary
                                                          .withValues(alpha:0.5),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              viewModel.searchText.isEmpty
                                                  ? 'No hay productos disponibles'
                                                  : 'No se encontraron productos',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isDark
                                                        ? Colors.white70
                                                        : AppColors
                                                            .textSecondary,
                                              ),
                                            ),
                                            if (viewModel
                                                .searchText
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                'Intenta con otros términos de búsqueda',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                              .withValues(alpha:0.6)
                                                          : AppColors
                                                              .textSecondary
                                                              .withValues(alpha:0.7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount:
                                      viewModel.getCategoriasVisibles().length,
                                  itemBuilder: (context, index) {
                                    final categoria =
                                        viewModel
                                            .getCategoriasVisibles()[index];
                                    return _buildCategoriaWidget(
                                      categoria,
                                      viewModel,
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                );
          },
        ),
        // 🎯 BOTÓN FLOTANTE PARA AGREGAR MENÚ - RESTAURADO
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgregarMenu()),
              );
              if (result == true) {
                // Recargar datos después de agregar un nuevo menú
                final viewModel = Provider.of<ProductosListViewModel>(
                  context,
                  listen: false,
                );
                viewModel.cargarDatosIniciales();
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: const Text(
              'Agregar Menú',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
