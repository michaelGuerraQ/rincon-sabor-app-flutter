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

  // CORRECCIÓN: Referencia segura al ScaffoldMessenger
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

  // CORRECCIÓN: Guardar referencia del ScaffoldMessenger
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

  // CORRECCIÓN: Método seguro para mostrar SnackBar
  void _mostrarSnackBarSeguro(String mensaje, {required Color backgroundColor, IconData? icono}) {
    if (_disposed || !mounted || _scaffoldMessenger == null) return;

    try {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: backgroundColor == AppColors.success
              ? const Duration(seconds: 3)
              : const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      print('Error mostrando SnackBar: $e');
    }
  }

  // CORRECCIÓN: Método de guardado seguro
  Future<void> _guardarMenu() async {
    if (_disposed || !mounted) return;

    try {
      print('🍽️ Iniciando creación de menú...');

      // Ejecutar submit y capturar resultado
      final ok = await _model.submit();

      print('🍽️ Resultado submit: $ok');

      if (!mounted || _disposed) return;

      if (ok) {
        print('✅ Menú creado exitosamente, navegando con resultado: true');

        // CORRECCIÓN: Navegar primero, luego mostrar mensaje
        Navigator.of(context).pop(true);

        // Mostrar mensaje en la pantalla anterior
        _mostrarSnackBarSeguro(
          'Menú agregado exitosamente',
          backgroundColor: AppColors.success,
          icono: Icons.check_circle,
        );
      } else {
        print('❌ Error en submit, mostrando mensaje de error');

        // ERROR: Mostrar mensaje sin navegar
        _mostrarSnackBarSeguro(
          'Error al agregar el menú. Intente nuevamente.',
          backgroundColor: AppColors.error,
          icono: Icons.error,
        );
      }
    } catch (e) {
      print('❌ Error inesperado al guardar menú: $e');

      if (!mounted || _disposed) return;

      _mostrarSnackBarSeguro(
        'Error inesperado: $e',
        backgroundColor: AppColors.error,
        icono: Icons.error,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
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
          fillColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.background,
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
    // CORRECCIÓN: Verificar disposed antes de construir
    if (_disposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : AppColors.primary,
              ),
              onPressed: () {
                if (!_disposed && mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          title: Text(
            'Agregar Menú',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Consumer<AgregarMenuModel>(
              builder: (context, m, _) {
                // CORRECCIÓN: Verificar disposed en cada build
                if (_disposed) return const SizedBox.shrink();

                return WillPopScope(
                  onWillPop: () async => !m.isSaving,
                  child: Form(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Header con icono
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.secondary.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryDark],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nuevo Plato',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Completa la información del menú',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Campos del formulario
                        _buildTextField(
                          controller: m.nameCtrl,
                          label: 'Nombre del plato',
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: m.descCtrl,
                          label: 'Descripción',
                          isDark: isDark,
                          maxLines: 3,
                        ),
                        _buildTextField(
                          controller: m.priceCtrl,
                          label: 'Precio (S/.)',
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                        ),

                        // Dropdown de categorías
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white30 : AppColors.divider,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: m.selectedCategoria,
                            dropdownColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                            items: m.categorias
                                .map((c) => DropdownMenuItem(
                              value: c.codigo,
                              child: Text(c.nombre),
                            ))
                                .toList(),
                            onChanged: (v) => m.selectedCategoria = v,
                            decoration: InputDecoration(
                              labelText: 'Categoría',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        // Switch para receta
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.divider,
                            ),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              '¿Tiene receta?',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Indica si este plato requiere preparación con insumos',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            value: m.esPreparado,
                            onChanged: m.togglePreparado,
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),

                        // Sección de receta
                        const RecetaSection(),
                        const SizedBox(height: 24),

                        // Selector de imagen
                        const ImagePickerField(),
                        const SizedBox(height: 32),

                        // Botón de guardar
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: m.isSaving
                                  ? [Colors.grey, Colors.grey]
                                  : [AppColors.primary, AppColors.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (m.isSaving ? Colors.grey : AppColors.primary)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: m.isSaving || _disposed ? null : _guardarMenu,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: m.isSaving
                                      ? [Colors.grey.shade600, Colors.grey.shade700]
                                      : [AppColors.primary, AppColors.secondary],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (m.isSaving) ...[
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ] else
                                      const Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      m.isSaving ? 'Guardando menú...' : 'Guardar Menú',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
