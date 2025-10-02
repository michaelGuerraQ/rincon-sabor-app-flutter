import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class Perfiladmin extends StatelessWidget {
  final Usuario? usuario;

  const Perfiladmin({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final photoUrl = firebaseUser?.photoURL;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [
                  const Color(0xFF1A202C),
                  const Color(0xFF2D3748),
                ]
              : [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.background,
                ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 32.0,
            ),
            child: Card(
              elevation: isDark ? 12 : 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar con borde gradiente
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor:
                            isDark ? const Color(0xFF2D3748) : Colors.white,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? Icon(Icons.person,
                                size: 80, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Nombre del usuario
                    Text(
                      usuario?.usuarioNombre ?? 'Nombre del Administrador',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Rol
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        usuario?.usuarioRol.toUpperCase() ?? 'ROL DESCONOCIDO',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Divider(
                      color: isDark 
                        ? Colors.white.withOpacity(0.2) 
                        : AppColors.divider,
                      thickness: 1.5,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Información del administrador
                    _buildInfoRow(
                      icon: Icons.badge,
                      label: 'ID Administrador',
                      value: usuario?.usuarioCodigo ?? 'Sin ID',
                      iconColor: AppColors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Correo Electrónico',
                      value: usuario?.usuarioEmail ?? 'Sin email',
                      iconColor: AppColors.info,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: usuario?.usuarioTelefono ?? 'Sin teléfono',
                      iconColor: AppColors.warning,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.check_circle,
                      label: 'Estado',
                      value: usuario?.usuarioEstado == 'A' ? 'Activo' : 'Inactivo',
                      iconColor: usuario?.usuarioEstado == 'A' 
                        ? AppColors.success 
                        : AppColors.error,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Fecha de Registro',
                      value: usuario?.usuarioFechaRegistro ?? 'Sin fecha',
                      iconColor: AppColors.secondary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Dirección',
                      value: usuario?.usuarioDireccion ?? 'Sin dirección',
                      iconColor: AppColors.primaryDark,
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Función de edición en desarrollo'),
                                  backgroundColor: AppColors.info,
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar Perfil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Configuración en desarrollo'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Configurar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withOpacity(0.05)
          : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1)
            : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              color: iconColor, 
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark 
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
