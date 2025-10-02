import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/screens/admin/main.dart';
import 'package:rincon_sabor_flutter/screens/cocina/pages/cocina_screen.dart';
import 'package:rincon_sabor_flutter/screens/home/components/custom_button.dart';
import 'package:rincon_sabor_flutter/screens/mesero/pages/seleccion_mesa_screen.dart';

class RoleRedirector extends StatelessWidget {
  final Usuario? usuario;
  final User firebaseUser;
  final AuthService authService;
  // final String name;
  // final String photoUrl;

  const RoleRedirector({
    super.key,
    required this.usuario,
    required this.firebaseUser,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    // print('Debug: usuario: $usuario');
    // print('Debug: estado: ${usuario?.usuarioEstado}');
    // print('Debug: rol: ${usuario?.usuarioRol}');

    // if (usuario == null || usuario!.estado == null) {
    if (usuario == null) {
      return _buildMensajeNoAutorizado(context);
    }

    if (usuario!.usuarioEstado != 'A') {
      return _buildMensajeNoAutorizado(context);
    }

    switch (usuario!.usuarioRol) {
      case 'admin':
        return AdminMain(usuario: usuario!);
        // return HomeScreen(usuarioApi: usuario!, firebaseUser: firebaseUser);
      case 'cocinero':
        return CocinaScreen();
      case 'mesero':
        return SeleccionMesaScreen();
      default:
        return _buildMensajeNoAutorizado(context);
    }
  }

  Widget _buildMensajeNoAutorizado(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rol no autorizado. Comunícate con el administrador',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Custombutton(
                text: 'Cerrar sesión',
                onPressed: () async {
                  await authService.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
