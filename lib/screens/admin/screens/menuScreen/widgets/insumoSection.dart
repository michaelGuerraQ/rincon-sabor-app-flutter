import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/view_model/agregar_view_model.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class InsumoSection extends StatelessWidget {
  const InsumoSection({super.key});

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    TextInputType? keyboardType,
    String? suffixText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            fontSize: 14,
          ),
          suffixStyle: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
            fontSize: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white30 : AppColors.divider,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white30 : AppColors.divider,
            ),
          ),
          filled: true,
          fillColor: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = context.watch<AgregarMenuModel>();
    
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Insumo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Datos básicos del producto',
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
          _buildTextField(
            controller: m.unitCtrl,
            label: 'Unidad de medida',
            isDark: isDark,
            suffixText: 'kg, und, lt',
          ),
          _buildTextField(
            controller: m.stockCtrl,
            label: 'Cantidad comprada (cantidad de unidades)',
            isDark: isDark,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          _buildTextField(
            controller: m.compraCtrl,
            label: 'Costo total de compra',
            isDark: isDark,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            suffixText: 'S/.',
          ),
        ],
      ),
    );
  }
}
