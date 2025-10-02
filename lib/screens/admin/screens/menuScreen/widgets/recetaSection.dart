import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/view_model/agregar_view_model.dart';
import 'package:rincon_sabor_flutter/core/models/DTO_MenuRequest.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'selectInsumosScreen.dart';
import 'insumoSection.dart';

class RecetaSection extends StatelessWidget {
  const RecetaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = Provider.of<AgregarMenuModel>(context);
    
    // Si no es preparado, mostramos la sección genérica
    if (!m.esPreparado) {
      return InsumoSection();
    }
    
    // Si es preparado, lista de insumos y detalles
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1)
            : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receta del Plato',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Insumos seleccionados: ${m.detalles.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Botón para elegir insumos
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (m.nameCtrl.text.isNotEmpty &&
                        m.priceCtrl.text.isNotEmpty &&
                        m.selectedCategoria != null)
                    ? [AppColors.warning, AppColors.warning.withOpacity(0.8)]
                    : [Colors.grey, Colors.grey.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (m.nameCtrl.text.isNotEmpty &&
                          m.priceCtrl.text.isNotEmpty &&
                          m.selectedCategoria != null)
                      ? AppColors.warning.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.list_rounded,
                color: Colors.white,
              ),
              label: Text(
                'Elegir insumos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: (m.nameCtrl.text.isNotEmpty &&
                      m.priceCtrl.text.isNotEmpty &&
                      m.selectedCategoria != null)
                  ? () async {
                      debugPrint('>> RecetaSection: antes de Navigator.push');
                      final result = await Navigator.push<List<RecetaDetalleRequest>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectInsumosScreen(
                            insumos: m.insumos,
                            detallesExistentes: m.detalles,
                          ),
                        ),
                      );
                      debugPrint('>> RecetaSection: regresó result=$result');
                      if (!context.mounted) return;
                      if (result != null) {
                        debugPrint('>> RecetaSection: antes de loadInsumos');
                        await m.loadInsumos();
                        debugPrint('>> RecetaSection: antes de postFrameCallback');
                        if (!context.mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          debugPrint('>> RecetaSection: dentro de postFrame, llamo setDetalles');
                          m.setDetalles(result);
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Lista de detalles de receta
          if (m.detalles.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Detalles de receta:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...m.detalles.map((d) {
              final insumo = m.insumos.firstWhere(
                (i) => i.codigo == d.insumoCodigo,
                orElse: () => throw Exception('Insumo ${d.insumoCodigo} no encontrado'),
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insumo.nombre!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: d.cantidadPorPlato.toString(),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          suffixText: insumo.unidadMedida,
                          suffixStyle: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white30 : AppColors.divider,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.surface,
                        ),
                        onChanged: (t) {
                          final c = double.tryParse(t) ?? 0;
                          m.updateDetalle(d.insumoCodigo, c);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () => m.removeDetalle(d.insumoCodigo),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
