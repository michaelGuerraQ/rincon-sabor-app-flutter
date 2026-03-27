import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/services/insumos_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class NewInsumoDialog extends StatefulWidget {
  const NewInsumoDialog({super.key});

  @override
  State<NewInsumoDialog> createState() => _NewInsumoDialogState();
}

class _NewInsumoDialogState extends State<NewInsumoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final ok = await InsumosService.crearInsumo(
      nombre: _nombreCtrl.text.trim(),
      unidadMedida: _unidadCtrl.text.trim(),
      stockActual: 0.0,
      compraUnidad: 0.0,
    );

    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('snackbar_error_insumo'),
          content: const Text('Error creando insumo'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      key: const Key('dialog_new_insumo'),
      backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        key: const Key('dialog_new_insumo_title'),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_box_rounded, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Text(
            'Nuevo Insumo',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          key: const Key('dialog_new_insumo_form'),
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              key: const Key('field_nombre_insumo'),
              controller: _nombreCtrl,
              label: 'Nombre del insumo',
              isDark: isDark,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              key: const Key('field_unidad_insumo'),
              controller: _unidadCtrl,
              label: 'Unidad (Kg, und, lt)',
              isDark: isDark,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('btn_cancelar_insumo_dialog'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _saving
                  ? [Colors.grey, Colors.grey.shade600]
                  : [AppColors.secondary, AppColors.secondaryDark],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            key: const Key('btn_guardar_insumo_dialog'),
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_saving) ...[
                  const SizedBox(
                    key: Key('progress_saving_insumo'),
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else
                  const Icon(Icons.save_rounded,
                      color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _saving ? 'Guardando...' : 'Guardar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
