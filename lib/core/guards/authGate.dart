// controla quién entra (verifica autenticación).
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/auth/pages/auth_screen.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/core/guards/RedirectByRole.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/core/services/usuarios_service.dart';

class Authgate extends StatelessWidget {
  final authService = AuthService();
  Authgate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      //detecta en tiempo real si el usuario está autenticado o no
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // print('Debug: Connection is waiting (loading).');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // print('Debug: Error de snapshot: ${snapshot.error}');
          return const Scaffold(
            body: Center(child: Text('Error al verificar sesión')),
          );
        } else if (!snapshot.hasData) {
          // print('Debug: No data found in snapshot: ${snapshot.data}');
          return const AuthScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<Usuario?>(
          future: UsuarioService.obtenerUsuarioAutenticado(),
          builder: (context, snapshotUsuario) {
            // print ('snapshotUsuario: ${snapshotUsuario.data}');
            if (snapshotUsuario.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // final usuario = snapshotUsuario.data;
            // if (usuario == null) return const WelcomePage();

            return RoleRedirector(
              usuario: snapshotUsuario.data,
              firebaseUser: user,
              authService: authService,
            );
          },
        );
      },
    );
  }
}
