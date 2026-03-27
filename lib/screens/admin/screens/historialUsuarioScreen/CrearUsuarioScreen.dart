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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _scaffoldMessenger = null;
    _animationController.dispose();
    super.dispose();
  }

  void _mostrarSnackBarSeguro(String mensaje, {required Color backgroundColor, IconData? icono}) {
    if (!mounted || _scaffoldMessenger == null) return;

    try {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          key: const Key('snackbar_mensaje'),
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final datos = _formKey.currentState!.value;
    setState(() => _cargando = true);

    try {
      final nuevoUsuario = Usuario(
        usuarioCodigo: '',
        usuarioNombre: datos['nombre'],
        usuarioEmail: datos['email'],
        usuarioDireccion: datos['direccion'] ?? '',
        usuarioTelefono: datos['telefono'] ?? '',
        usuarioFechaRegistrosinFormatear: '',
        usuarioEstado: 'A',
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
        Navigator.pop(context, true);
      } else {
        _mostrarSnackBarSeguro(
          'Error al crear usuario',
          backgroundColor: AppColors.error,
          icono: Icons.error,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _mostrarSnackBarSeguro(
        'Error al crear usuario: $e',
        backgroundColor: AppColors.error,
        icono: Icons.error,
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: const Key('crear_usuario_screen'),
      backgroundColor: isDark ? const Color(0xFF1A202C) : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    key: const Key('btn_back'),
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
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.person_add, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Crear Usuario',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            key: const Key('field_nombre'),
                            name: 'nombre',
                            label: 'Nombre completo',
                            icon: Icons.person_outline,
                            validator: FormBuilderValidators.required(),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            key: const Key('field_email'),
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
                            key: const Key('field_direccion'),
                            name: 'direccion',
                            label: 'Dirección',
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            key: const Key('field_telefono'),
                            name: 'telefono',
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          const DropdownRolUsuario(key: Key('dropdown_rol')),
                          const SizedBox(height: 32),
                          _buildSaveButton(isDark),
                        ],
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
    required Key key,
    required String name,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return FormBuilderTextField(
      key: key,
      name: name,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      key: const Key('btn_guardar'),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cargando
              ? [Colors.grey, Colors.grey.shade400]
              : [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _cargando ? null : _guardar,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _cargando
                ? const CircularProgressIndicator(
              key: Key('progress_guardar'),
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white),
                SizedBox(width: 8),
                Text('Crear Usuario',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
