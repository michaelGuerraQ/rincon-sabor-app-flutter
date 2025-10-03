import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/core/services/usuarios_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/widgets/DropdownRolUsuario.dart';

class CrearUsuarioScreen extends StatefulWidget {
  const CrearUsuarioScreen({super.key});

  @override
  State<CrearUsuarioScreen> createState() => _CrearUsuarioScreenState();
}

class _CrearUsuarioScreenState extends State<CrearUsuarioScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _cargando = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // CORRECCIÓN: Añadir referencia segura al ScaffoldMessenger
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  // CORRECCIÓN: Guardar referencia del ScaffoldMessenger
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _scaffoldMessenger = null; // CORRECCIÓN: Limpiar referencia
    _animationController.dispose();
    super.dispose();
  }

  // CORRECCIÓN: Método seguro para mostrar SnackBar
  void _mostrarSnackBarSeguro(String mensaje, {required Color backgroundColor, IconData? icono}) {
    if (!mounted || _scaffoldMessenger == null) return;

    try {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(mensaje, style: const TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      print('Error mostrando SnackBar: $e');
    }
  }

  // CORRECCIÓN CRÍTICA: Método guardar seguro sin UI optimista
  Future<void> _guardar() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final datos = _formKey.currentState!.value;

    // CORRECCIÓN: NO crear el usuario inmediatamente en UI
    setState(() {
      _cargando = true;
    });

    try {
      print('🔄 Creando usuario: ${datos['nombre']}');

      final nuevoUsuario = Usuario(
        usuarioCodigo: '', // El backend asigna el código
        usuarioNombre: datos['nombre'],
        usuarioEmail: datos['email'],
        usuarioDireccion: datos['direccion'] ?? '',
        usuarioTelefono: datos['telefono'] ?? '',
        usuarioFechaRegistrosinFormatear: '', // El backend asigna la fecha
        usuarioEstado: 'A', // Activo por defecto
        usuarioRol: datos['rol'],
      );

      final creado = await UsuarioService.crearUsuario(nuevoUsuario);

      if (!mounted) return;

      if (creado) {
        _mostrarSnackBarSeguro(
          'Usuario creado correctamente',
          backgroundColor: AppColors.success,
          icono: Icons.check_circle,
        );

        print('✅ Usuario creado exitosamente');

        // CORRECCIÓN: Retornar true para confirmar la creación
        Navigator.pop(context, true);
      } else {
        _mostrarSnackBarSeguro(
          'Error al crear usuario',
          backgroundColor: AppColors.error,
          icono: Icons.error,
        );
        print('❌ Error: Backend retornó false');
      }
    } catch (e) {
      if (!mounted) return;

      _mostrarSnackBarSeguro(
        'Error al crear usuario: $e',
        backgroundColor: AppColors.error,
        icono: Icons.error,
      );
      print('❌ Error en crear: $e');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A202C) : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // AppBar personalizado
                SliverAppBar(
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  // Icono con gradiente
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Crear Usuario',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Completa la información del nuevo usuario',
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Formulario
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D3748) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                name: 'nombre',
                                label: 'Nombre completo',
                                icon: Icons.person_outline,
                                validator: FormBuilderValidators.required(),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                name: 'email',
                                label: 'Correo electrónico',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.email(),
                                ]),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                name: 'direccion',
                                label: 'Dirección',
                                icon: Icons.location_on_outlined,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                name: 'telefono',
                                label: 'Teléfono',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 20),

                              const DropdownRolUsuario(),
                              const SizedBox(height: 32),

                              _buildSaveButton(isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String name,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return FormBuilderTextField(
      name: name,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1A202C).withOpacity(0.5)
            : AppColors.background.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : AppColors.textSecondary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _cargando
              ? [Colors.grey, Colors.grey.shade400]
              : [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: !_cargando
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _cargando ? null : _guardar,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _cargando
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Crear Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
