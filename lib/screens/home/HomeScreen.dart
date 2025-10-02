import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/core/models/Usuario.dart';
import 'package:rincon_sabor_flutter/screens/admin/main.dart';
import 'package:rincon_sabor_flutter/screens/cocina/pages/cocina_screen.dart';
import 'package:rincon_sabor_flutter/screens/home/components/custom_button.dart';
import 'package:rincon_sabor_flutter/screens/mesero/pages/seleccion_mesa_screen.dart';

class HomeScreen extends StatefulWidget {

  final User firebaseUser;
  final Usuario usuarioApi;
  
  // final String email;
  // final String name;
  // final String photoUrl;
  const HomeScreen({
    super.key,
    required this.firebaseUser,
    required this.usuarioApi,
    // this.email = '',
    // this.name = '',
    // this.photoUrl = '',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Aquí puedes manejar estados si es necesario, por ejemplo:
  // String? _rolSeleccionado;
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Lista de roles y sus respectivas acciones
    List<Map<String, dynamic>> roles = [
      {
        'text': 'Mesero',
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeleccionMesaScreen()),
          );
        },
      },
      {
        'text': 'Cocina',
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CocinaScreen()),
          );
        },
      },
      {
        'text': 'Administrador',
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminMain( usuario:widget.usuarioApi)),
          );
        },
      },
      {
        'text': 'cerrar secion',
        'onPressed': () async {
          try {
            await authService.signOut();
            // YA NO EES NECESARIO NAVEGAR YA QUE TODO LA NAVEGACION SE HACE EN EL GUARD
            // if (!mounted) return;
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (context) => WelcomePage()),
            //   (route) => false,
            // );
          } catch (e) {
            print('Ocurrió un error: $e');
          }
        },
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/img_fondo_base.jpg'),
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              Column(
                children:
                    roles.map((rol) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Custombutton(
                          text: rol['text'],
                          onPressed: rol['onPressed'],
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  // Este widget es privado y solo se utiliza dentro de esta clase
  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "¡BIENVENIDO!",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Elige tu rol dentro del equipo",
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 40,
          backgroundImage:
              widget.firebaseUser.photoURL != null && widget.firebaseUser.photoURL!.isNotEmpty
                  ? NetworkImage(widget.firebaseUser.photoURL!)
                  : const AssetImage('assets/user_placeholder.png')//cambiar co un placeholder
                      as ImageProvider,
        ),
        const SizedBox(height: 10),
        Text(
          widget.firebaseUser.displayName ?? 'error al obtener el nombre',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
          widget.firebaseUser.email ?? 'error al obtener el email',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}
