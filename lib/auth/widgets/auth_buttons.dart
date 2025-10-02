import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthButtons extends StatelessWidget {
  final AuthService authService;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSuccess;
  final void Function(String) onError;

  const AuthButtons({
    super.key,
    required this.authService,
    required this.emailController,
    required this.passwordController,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            try {
              await authService.signInWithEmail(
                emailController.text.trim(),
                passwordController.text.trim(),
              );
              onSuccess();
            } catch (e) {
              onError(e.toString());
            }
          },
          child: const Text('Ingresar con Email'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              await authService.signInWithGoogle();
              onSuccess();
            } catch (e) {
              onError(e.toString());
            }
          },
          icon: const Icon(Icons.login),
          label: const Text('Iniciar con Google'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}
