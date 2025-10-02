import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/core/services/usuarios_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/historialUsuarioScreen/EditarUsuarioScreen.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/historialUsuarioScreen/infoUsuarioScreen.dart';

class UsuarioCard extends StatefulWidget {
  final Usuario usuario;
  final bool seleccionado;
  final bool cargando;
  final bool enModoEdicion;
  final ValueChanged<bool?>? onChanged;
  final ValueChanged<bool> onModoEdicionChanged;
  final VoidCallback onUsuarioEliminado;
  final VoidCallback onUsuarioActualizado;

  const UsuarioCard({
    super.key,
    required this.usuario,
    required this.seleccionado,
    required this.onChanged,
    this.cargando = false,
    this.enModoEdicion = false,
    required this.onModoEdicionChanged,
    required this.onUsuarioEliminado,
    required this.onUsuarioActualizado,
  });

  @override
  State<UsuarioCard> createState() => _UsuarioCardState();
}

class _UsuarioCardState extends State<UsuarioCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _esActivo => widget.usuario.usuarioEstado == 'A';
  bool get _esAdmin => widget.usuario.usuarioRol.toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: () => widget.onModoEdicionChanged(!widget.enModoEdicion),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: widget.enModoEdicion
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha:0.5),
                        width: 2,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withValues(alpha:0.3)
                        : Colors.black.withValues(alpha:0.08),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                  if (widget.enModoEdicion)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha:0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _AvatarUsuario(
                      usuario: widget.usuario,
                      esActivo: _esActivo,
                      esAdmin: _esAdmin,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoUsuario(
                        usuario: widget.usuario,
                        esActivo: _esActivo,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _AccionesUsuario(
                      enModoEdicion: widget.enModoEdicion,
                      cargando: widget.cargando,
                      seleccionado: widget.seleccionado,
                      esAdmin: _esAdmin,
                      onChanged: widget.onChanged,
                      usuario: widget.usuario,
                      onUsuarioEliminado: widget.onUsuarioEliminado,
                      onUsuarioActualizado: widget.onUsuarioActualizado,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarUsuario extends StatelessWidget {
  final Usuario usuario;
  final bool esActivo;
  final bool esAdmin;

  const _AvatarUsuario({
    required this.usuario,
    required this.esActivo,
    required this.esAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: esAdmin
                  ? [AppColors.warning, AppColors.secondary]
                  : [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: (esAdmin ? AppColors.warning : AppColors.primary).withValues(alpha:0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            child: Icon(
              esAdmin ? Icons.admin_panel_settings : Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: esActivo ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoUsuario extends StatelessWidget {
  final Usuario usuario;
  final bool esActivo;
  final bool isDark;

  const _InfoUsuario({
    required this.usuario,
    required this.esActivo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                usuario.usuarioNombre,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: esActivo 
                    ? AppColors.success.withValues(alpha:0.1)
                    : AppColors.error.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: esActivo 
                      ? AppColors.success.withValues(alpha:0.3)
                      : AppColors.error.withValues(alpha:0.3),
                ),
              ),
              child: Text(
                esActivo ? 'ACTIVO' : 'INACTIVO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: esActivo ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            usuario.usuarioRol.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (usuario.usuarioTelefono.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 14,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                usuario.usuarioTelefono,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Icon(
              Icons.email,
              size: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                usuario.usuarioEmail,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccionesUsuario extends StatelessWidget {
  final bool enModoEdicion;
  final bool cargando;
  final bool seleccionado;
  final bool esAdmin;
  final ValueChanged<bool?>? onChanged;
  final Usuario usuario;
  final VoidCallback onUsuarioEliminado;
  final VoidCallback onUsuarioActualizado;
  final bool isDark;

  const _AccionesUsuario({
    required this.enModoEdicion,
    required this.cargando,
    required this.seleccionado,
    required this.esAdmin,
    required this.onChanged,
    required this.usuario,
    required this.onUsuarioEliminado,
    required this.onUsuarioActualizado,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: enModoEdicion
          ? _BotonesEdicion(
              key: const ValueKey('edicion'),
              usuario: usuario,
              onUsuarioEliminado: onUsuarioEliminado,
              onUsuarioActualizado: onUsuarioActualizado,
              isDark: isDark,
            )
          : (!esAdmin
              ? (cargando
                  ? Container(
                      key: const ValueKey('loading'),
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Transform.scale(
                      key: const ValueKey('checkbox'),
                      scale: 1.2,
                      child: Checkbox(
                        value: seleccionado,
                        onChanged: onChanged,
                        activeColor: AppColors.success,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ))
              : Container(
                  key: const ValueKey('admin'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha:0.3),
                    ),
                  ),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                )),
    );
  }
}

class _BotonesEdicion extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onUsuarioEliminado;
  final VoidCallback onUsuarioActualizado;
  final bool isDark;

  const _BotonesEdicion({
    super.key,
    required this.usuario,
    required this.onUsuarioEliminado,
    required this.onUsuarioActualizado,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconoAccion(
          icono: Icons.visibility,
          color: AppColors.info,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InfoUsuarioScreen(usuario: usuario),
            ),
          ),
          isDark: isDark,
        ),
        const SizedBox(width: 4),
        _IconoAccion(
          icono: Icons.edit,
          color: AppColors.primary,
          onTap: () async {
            final actualizado = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditarUsuarioScreen(usuario: usuario),
              ),
            );

            if (actualizado == true) {
              onUsuarioActualizado();
            }
          },
          isDark: isDark,
        ),
        const SizedBox(width: 4),
        _IconoAccion(
          icono: Icons.delete_outline,
          color: AppColors.error,
          onTap: () async {
            final confirmar = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  '¿Eliminar usuario?',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                content: Text(
                  '¿Estás seguro de eliminar a "${usuario.usuarioNombre}"? Esta acción no se puede deshacer.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.error, AppColors.error.withValues(alpha:0.8)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (confirmar == true) {
              final eliminado = await UsuarioService.eliminarUsuario(
                usuario.usuarioCodigo,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          eliminado ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          eliminado
                              ? 'Usuario eliminado correctamente'
                              : 'Error al eliminar usuario',
                        ),
                      ],
                    ),
                    backgroundColor: eliminado ? AppColors.success : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                if (eliminado) {
                  onUsuarioEliminado();
                }
              }
            }
          },
          isDark: isDark,
        ),
      ],
    );
  }
}

class _IconoAccion extends StatefulWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _IconoAccion({
    required this.icono,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_IconoAccion> createState() => _IconoAccionState();
}

class _IconoAccionState extends State<_IconoAccion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.color.withValues(alpha:0.3),
                ),
              ),
              child: Icon(
                widget.icono,
                size: 18,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
