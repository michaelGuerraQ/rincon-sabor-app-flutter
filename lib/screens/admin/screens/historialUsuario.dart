// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/core/services/usuarios_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/widgets/input_search.dart';
import 'package:rincon_sabor_flutter/screens/admin/components/usuario_card.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/historialUsuarioScreen/CrearUsuarioScreen.dart';

class HistorialUsuario extends StatefulWidget {
  const HistorialUsuario({super.key});

  @override
  State<HistorialUsuario> createState() => _HistorialUsuarioState();
}

class _HistorialUsuarioState extends State<HistorialUsuario> {
  List<Usuario> usuarios = [];
  List<Usuario> usuariosFiltrados = [];
  final TextEditingController _searchController = TextEditingController();
  Usuario? usuarioLogueado; 
  Map<int, bool> estadosCargando = {};
  int? tarjetaEnModoEdicion;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> cargarUsuarios() async {
    try {
      final all = await UsuarioService.obtenerTodosLosUsuarios();
      final auth = await UsuarioService.obtenerUsuarioAutenticado();
      final filtered = all.where((u) => u.usuarioCodigo != auth?.usuarioCodigo).toList();

      if (!mounted) return;
      setState(() {
        usuarios = filtered;
        usuariosFiltrados = filtered;
        usuarioLogueado = auth;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _filtrarUsuarios(String query) {
    final q = query.toLowerCase();
    setState(() {
      usuariosFiltrados = usuarios.where((u) =>
        u.usuarioNombre.toLowerCase().contains(q) ||
        u.usuarioEmail.toLowerCase().contains(q) ||
        u.usuarioCodigo.toLowerCase().contains(q) ||
        u.usuarioRol.toLowerCase().contains(q)
      ).toList();
    });
  }

  Future<void> cambiarEstado(int index, bool activo) async {
    final nuevoEstado = activo ? 'A' : 'I';
    final estadoAnterior = usuarios[index].usuarioEstado;

    // Marcar como cargando
    setState(() {
      estadosCargando[index] = true;
      usuarios[index].usuarioEstado = nuevoEstado; // UI optimista
    });

    try {
      final actualizado = await UsuarioService.actualizarEstadoUsuario(
        usuarios[index].usuarioCodigo,
        nuevoEstado,
      );

      // CORRECCIÓN: Verificar mounted antes de usar context
      if (!mounted) return;

      if (!actualizado) {
        // Si falló, restaurar estado anterior
        setState(() {
          usuarios[index].usuarioEstado = estadoAnterior;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo actualizar el estado'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario ${activo ? 'activado' : 'desactivado'} correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // CORRECCIÓN: Verificar mounted antes de usar context
      if (!mounted) return;

      // Restaurar estado anterior
      setState(() {
        usuarios[index].usuarioEstado = estadoAnterior;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar estado: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      // CORRECCIÓN: Verificar mounted antes de setState
      if (mounted) {
        setState(() {
          estadosCargando[index] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (cargando) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
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
                        ? Colors.black.withValues(alpha:0.3)
                        : Colors.grey.withValues(alpha:0.1),
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
                'Cargando usuarios...',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        title: Text(
          'Gestión de Usuarios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: cargarUsuarios,
        color: AppColors.primary,
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Barra de búsqueda
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Buscar usuario...',
                onChanged: _filtrarUsuarios,
              ),
            ),
            
            // Tarjeta del usuario logueado
            if (usuarioLogueado != null) ...[
              LoggedInUsuarioCard(usuario: usuarioLogueado!),
              const SizedBox(height: 24),
            ],
            
            // Header de la lista de usuarios
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.people_rounded,
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
                          'Usuarios Registrados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${usuariosFiltrados.length} usuarios encontrados',
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
            ),
            
            // Lista de usuarios
            ...usuariosFiltrados.asMap().entries.map((entry) {
              final idx = entry.key;
              final u = entry.value;
              return UsuarioCard(
                usuario: u,
                seleccionado: u.usuarioEstado == 'A',
                cargando: estadosCargando[idx] == true,
                enModoEdicion: tarjetaEnModoEdicion == idx,
                onModoEdicionChanged: (act) => setState(() {
                  tarjetaEnModoEdicion = act ? idx : null;
                }),
                onChanged: estadosCargando[idx] == true
                    ? null
                    : (nv) => cambiarEstado(idx, nv ?? false),
                onUsuarioEliminado: cargarUsuarios,
                onUsuarioActualizado: cargarUsuarios,
              );
            }).toList(),
            
            // Espaciado adicional para el FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
      
      // Botón flotante para crear usuario
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            final creado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CrearUsuarioScreen()),
            );

            if (creado == true) {
              cargarUsuarios(); // actualiza lista si se creó usuario
            }
          },
          icon: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'Crear Usuario',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class LoggedInUsuarioCard extends StatelessWidget {
  final Usuario usuario;
  const LoggedInUsuarioCard({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [
                const Color(0xFF2D3748),
                const Color(0xFF4A5568),
              ]
            : [
                AppColors.primary.withValues(alpha:0.1),
                AppColors.secondary.withValues(alpha:0.1),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha:0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? Colors.black.withValues(alpha:0.3)
              : AppColors.primary.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar con diseño mejorado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usuario.usuarioNombre,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha:0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 12,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Activo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rol
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      usuario.usuarioRol.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email
                  Row(
                    children: [
                      Icon(
                        Icons.email_rounded,
                        size: 14,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          usuario.usuarioEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
