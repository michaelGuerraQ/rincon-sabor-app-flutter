import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/view_model/agregar_view_model.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/widgets/imagePickerField.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/widgets/recetaSection.dart';

class AgregarMenu extends StatefulWidget {
  const AgregarMenu({super.key});

  @override
  AgregarMenuState createState() => AgregarMenuState();
}

class AgregarMenuState extends State<AgregarMenu> with TickerProviderStateMixin {
  late final AgregarMenuModel _model;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  ScaffoldMessengerState? _scaffoldMessenger;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _model = AgregarMenuModel();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_disposed) {
      _scaffoldMessenger = ScaffoldMessenger.of(context);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _scaffoldMessenger = null;
    _animationController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _mostrarSnackBarSeguro(String mensaje, {required Color backgroundColor, IconData? icono}) {
    if (_disposed || !mounted || _scaffoldMessenger == null) return;

    try {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          key: const Key('snackbar_agregar_menu'),
          content: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(mensaje,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      print('Error mostrando SnackBar: $e');
    }
  }

  Future<void> _guardarMenu() async {
    if (_disposed || !mounted) return;

    try {
      final ok = await _model.submit();

      if (!mounted || _disposed) return;

      if (ok) {
        Navigator.of(context).pop(true);
        _mostrarSnackBarSeguro(
          'Menú agregado exitosamente',
          backgroundColor: AppColors.success,
          icono: Icons.check_circle,
        );
      } else {
        _mostrarSnackBarSeguro(
          'Error al agregar el menú. Intente nuevamente.',
          backgroundColor: AppColors.error,
          icono: Icons.error,
        );
      }
    } catch (e) {
      if (!mounted || _disposed) return;
      _mostrarSnackBarSeguro(
        'Error inesperado: $e',
        backgroundColor: AppColors.error,
        icono: Icons.error,
      );
    }
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.background,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        key: const Key('agregar_menu_screen'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          key: const Key('appbar_agregar_menu'),
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
          leading: IconButton(
            key: const Key('btn_back_menu'),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Agregar Menú'),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Consumer<AgregarMenuModel>(
              builder: (context, m, _) {
                if (_disposed) return const SizedBox.shrink();

                return Form(
                  key: const Key('form_agregar_menu'),
                  child: ListView(
                    key: const Key('scroll_agregar_menu'),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildTextField(
                        key: const Key('field_nombre_plato'),
                        controller: m.nameCtrl,
                        label: 'Nombre del plato',
                        isDark: isDark,
                      ),
                      _buildTextField(
                        key: const Key('field_descripcion_plato'),
                        controller: m.descCtrl,
                        label: 'Descripción',
                        isDark: isDark,
                        maxLines: 3,
                      ),
                      _buildTextField(
                        key: const Key('field_precio_plato'),
                        controller: m.priceCtrl,
                        label: 'Precio (S/.)',
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                      ),

                      // Dropdown de categorías
                      DropdownButtonFormField<String>(
                        key: const Key('dropdown_categoria'),
                        value: m.selectedCategoria,
                        items: m.categorias
                            .map((c) => DropdownMenuItem(
                          value: c.codigo,
                          child: Text(c.nombre),
                        ))
                            .toList(),
                        onChanged: (v) => m.selectedCategoria = v,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                      ),
                      const SizedBox(height: 20),

                      // Switch tiene receta
                      SwitchListTile(
                        key: const Key('switch_tiene_receta'),
                        title: const Text('¿Tiene receta?'),
                        value: m.esPreparado,
                        onChanged: m.togglePreparado,
                        activeColor: AppColors.primary,
                      ),

                      const RecetaSection(key: Key('receta_section')),
                      const ImagePickerField(key: Key('image_picker_field')),
                      const SizedBox(height: 32),

                      // Botón guardar
                      SizedBox(
                        key: const Key('btn_guardar_menu'),
                        height: 56,
                        child: ElevatedButton(
                          onPressed: m.isSaving ? null : _guardarMenu,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: m.isSaving
                              ? const CircularProgressIndicator(
                              key: Key('progress_guardar_menu'),
                              color: Colors.white)
                              : const Text(
                            'Guardar Menú',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
