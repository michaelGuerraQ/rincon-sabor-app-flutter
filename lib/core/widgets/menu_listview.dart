import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/menu.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class MenuListView extends StatelessWidget {
  final List<Menu> menu;
  final Widget Function(Menu menu)? actionIcon;

  const MenuListView({required this.menu, super.key, required this.actionIcon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.builder(
      itemCount: menu.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = menu[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                ? [
                    const Color(0xFF2D3748),
                    const Color(0xFF2D3748).withValues(alpha:0.95),
                  ]
                : [
                    AppColors.surface,
                    AppColors.background,
                  ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.menuDisponible
                ? AppColors.primary.withValues(alpha:0.2)
                : AppColors.error.withValues(alpha:0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                  ? Colors.black.withValues(alpha:0.3)
                  : Colors.grey.withValues(alpha:0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (item.menuDisponible)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha:0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.menuDisponible
                        ? AppColors.primary.withValues(alpha:0.3)
                        : AppColors.error.withValues(alpha:0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.menuDisponible
                          ? AppColors.primary.withValues(alpha:0.2)
                          : AppColors.error.withValues(alpha:0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        ? Image.network(
                            item.imageUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder(Icons.broken_image, isDark);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isDark 
                                    ? const Color(0xFF4A5568)
                                    : AppColors.background,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildImagePlaceholder(Icons.restaurant_rounded, isDark),
                  ),
                ),

                const SizedBox(width: 16),

                // Información del menú
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.platos,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Precio con diseño mejorado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withValues(alpha:0.1),
                              AppColors.primary.withValues(alpha:0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha:0.3),
                          ),
                        ),
                        child: Text(
                          'S/ ${item.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Estado de disponibilidad mejorado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.menuDisponible
                            ? AppColors.success.withValues(alpha:0.1)
                            : AppColors.error.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.menuDisponible
                              ? AppColors.success.withValues(alpha:0.3)
                              : AppColors.error.withValues(alpha:0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: item.menuDisponible
                                  ? AppColors.success
                                  : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.menuDisponible ? 'Disponible' : 'Agotado',
                              style: TextStyle(
                                color: item.menuDisponible
                                  ? AppColors.success
                                  : AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Botón de acción opcional
                if (actionIcon != null) actionIcon!(item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(IconData icon, bool isDark) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [
                const Color(0xFF4A5568),
                const Color(0xFF4A5568).withValues(alpha:0.8),
              ]
            : [
                AppColors.background,
                AppColors.divider.withValues(alpha:0.5),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: AppColors.primary.withValues(alpha:0.7),
        size: 28,
      ),
    );
  }
}
