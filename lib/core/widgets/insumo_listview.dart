import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';
import 'package:rincon_sabor_flutter/core/widgets/insumoCard.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class InsumoListview extends StatelessWidget {
  final List<Insumos> insumos;
  final Future<bool> Function(Insumos) onActualizar;
  final Future<bool> Function(Insumos) onEliminar;
  final Future<bool> Function(Insumos) onEditar;
  final bool cargandoGlobal;

  const InsumoListview({
    super.key,
    required this.insumos,
    required this.onActualizar,
    required this.onEliminar,
    required this.onEditar,
    this.cargandoGlobal = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (cargandoGlobal) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
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
              'Cargando insumos...',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: insumos.length,
      itemBuilder: (ctx, i) {
        final ins = insumos[i];
        return InsumoCard(
          insumo: ins,
          cargando: false,
          onEditar: onEditar,
          onActualizar: onActualizar,
          onEliminar: onEliminar,
        );
      },
    );
  }
}
