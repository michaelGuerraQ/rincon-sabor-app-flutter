import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/models/menu.dart';
import 'package:rincon_sabor_flutter/core/view_model/seleccion_platos_view_model.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart' show AppColors;
import 'menu_item_card.dart';

class MenuCategorySection extends StatelessWidget {
  final Categoria categoria;
  final GlobalKey fabKey;
  final Function(Offset) runAddBubble;

  const MenuCategorySection({
    super.key,
    required this.categoria,
    required this.fabKey,
    required this.runAddBubble,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SeleccionPlatosViewModel>(
      builder: (context, vm, child) {
        // Obtener TODOS los menús de esta categoría (sin filtrar por búsqueda aún)
        final todosLosMenusDeCategoria =
            vm.menus
                .where(
                  (menu) =>
                      menu.categoria?.codigo == categoria.codigo &&
                      menu.estado == 'A', // <-- sólo los activos
                )
                .toList();

        // Filtrar por búsqueda solo para mostrar
        final menusVisibles =
            todosLosMenusDeCategoria.where((menu) {
              if (vm.searchText.isEmpty) return true;
              return menu.platos.toLowerCase().contains(
                    vm.searchText.toLowerCase(),
                  ) ||
                  menu.descripcion.toLowerCase().contains(
                    vm.searchText.toLowerCase(),
                  );
            }).toList();

        final isVisible = vm.visibles[categoria.nombre] ?? true;

        // SIEMPRE mostrar la categoría, incluso si está vacía
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3748), // Superficie dark
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la categoría (SIEMPRE visible)
              InkWell(
                onTap: () => vm.toggleCategoria(categoria.nombre),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: isVisible ? Radius.zero : const Radius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.secondary.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(20),
                      bottom:
                          isVisible ? Radius.zero : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.3),
                              AppColors.secondary.withValues(alpha: 0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoria.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSubtitle(
                                todosLosMenusDeCategoria,
                                menusVisibles,
                                vm.searchText,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    todosLosMenusDeCategoria.isEmpty
                                        ? Colors.white38
                                        : Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          isVisible
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido de la categoría (solo visible si está expandida)
              if (isVisible)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1A202C,
                    ), // Fondo más oscuro para el contenido
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: _buildContent(
                    todosLosMenusDeCategoria,
                    menusVisibles,
                    vm,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getSubtitle(
    List<Menu> todosLosMenus,
    List<Menu> menusVisibles,
    String searchText,
  ) {
    if (todosLosMenus.isEmpty) {
      return 'Sin platos en esta categoría';
    }

    if (searchText.isNotEmpty && menusVisibles.isEmpty) {
      return 'No se encontraron platos con "$searchText"';
    }

    if (searchText.isNotEmpty) {
      return '${menusVisibles.length} de ${todosLosMenus.length} platos encontrados';
    }

    return '${todosLosMenus.length} plato${todosLosMenus.length == 1 ? '' : 's'} disponible${todosLosMenus.length == 1 ? '' : 's'}';
  }

  Widget _buildContent(
    List<Menu> todosLosMenus,
    List<Menu> menusVisibles,
    SeleccionPlatosViewModel vm,
  ) {
    // Si no hay menús en absoluto en esta categoría
    if (todosLosMenus.isEmpty) {
      return _buildEmptyState(
        'No hay platos en esta categoría',
        'Los platos aparecerán aquí cuando estén disponibles',
        Icons.no_meals_outlined,
      );
    }

    // Si hay menús pero ninguno coincide con la búsqueda
    if (vm.searchText.isNotEmpty && menusVisibles.isEmpty) {
      return _buildEmptyState(
        'No se encontraron platos',
        'Intenta con otros términos de búsqueda',
        Icons.search_off_rounded,
      );
    }

    // Mostrar los menús visibles
    return Column(
      children:
          menusVisibles.map((menu) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: MenuItemCard(
                menu: menu,
                onAdd: (offset) {
                  vm.addToPedido(menu);
                  runAddBubble(offset);
                },
              ),
            );
          }).toList(),
    );
  }

  /// Construye un estado vacío con un título, subtítulo e ícono.
  /// Utilizado para mostrar mensajes cuando no hay platos disponibles o no se encuentran resultados.
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
