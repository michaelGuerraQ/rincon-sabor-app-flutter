import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/core/services/usuarios_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/widgets/DropdownRolUsuario.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Usuario usuario;

  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen>
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

  void _mostrarSnackBarSeguro(String mensaje, {required Color backgroundColor}) {
    if (!mounted || _scaffoldMessenger == null) return;

    try {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          key: const Key('snackbar_editar_usuario'),
          content: Row(
            children: [
              Icon(
                backgroundColor == AppColors.success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
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

  Future<void> _actualizar() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final datos = _formKey.currentState!.value;
    setState(() => _cargando = true);

    try {
      final usuarioActualizado = Usuario(
        usuarioCodigo: widget.usuario.usuarioCodigo,
        usuarioNombre: datos['nombre'],
        usuarioEmail: datos['email'],
        usuarioDireccion: datos['direccion'] ?? '',
        usuarioTelefono: datos['telefono'] ?? '',
        usuarioFechaRegistrosinFormatear: widget.usuario.usuarioFechaRegistrosinFormatear,
        usuarioEstado: widget.usuario.usuarioEstado,
        usuarioRol: datos['rol'],
      );

      final actualizado = await UsuarioService.actualizarUsuario(usuarioActualizado);

      if (!mounted) return;

      if (actualizado) {
        _mostrarSnackBarSeguro(
          'Usuario actualizado correctamente',
          backgroundColor: AppColors.success,
        );
        Navigator.pop(context, true);
      } else {
        _mostrarSnackBarSeguro(
          'No se pudo actualizar el usuario',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBarSeguro(
        'Error al actualizar usuario: $e',
        backgroundColor: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: const Key('editar_usuario_screen'),
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
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    key: const Key('btn_back_editar'),
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: const FlexibleSpaceBar(
                    background: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2D9CDB), Color(0xFF56CCF2)],
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
                      initialValue: {
                        'nombre': widget.usuario.usuarioNombre,
                        'email': widget.usuario.usuarioEmail,
                        'direccion': widget.usuario.usuarioDireccion,
                        'telefono': widget.usuario.usuarioTelefono,
                        'rol': widget.usuario.usuarioRol,
                      },
                      child: Column(
                        children: [
                          _buildTextField(
                            key: const Key('edit_field_nombre'),
                            name: 'nombre',
                            label: 'Nombre completo',
                            icon: Icons.person_outline,
                            validator: FormBuilderValidators.required(),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            key: const Key('edit_field_email'),
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
                            key: const Key('edit_field_direccion'),
                            name: 'direccion',
                            label: 'Dirección',
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            key: const Key('edit_field_telefono'),
                            name: 'telefono',
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          const DropdownRolUsuario(key: Key('edit_dropdown_rol')),
                          const SizedBox(height: 32),
                          _buildUpdateButton(isDark),
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
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.info),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildUpdateButton(bool isDark) {
    return Container(
      key: const Key('btn_actualizar'),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cargando
              ? [Colors.grey, Colors.grey.shade400]
              : [AppColors.info, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _cargando ? null : _actualizar,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _cargando
                ? const CircularProgressIndicator(
              key: Key('progress_actualizar'),
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.update, color: Colors.white),
                SizedBox(width: 8),
                Text('Actualizar Usuario',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
