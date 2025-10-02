// lib/auth/pages/screens/welcome.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/theme/app_colors.dart';
import '../../components/BlurContainer.dart';
import '../../services/auth_service.dart';
import '../../widgets/AppFormField.dart';
import '../../widgets/my_button.dart';
import '../../widgets/square_tile.dart';

class WelcomePage extends StatefulWidget {
  final void Function(
    String email,
    bool exists,
    String? photoUrl,
    AuthCredential? pendingCredential,
  )
  onNext;

  const WelcomePage({super.key, required this.onNext});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      final exists = await AuthService().isEmailRegistered(email);
      widget.onNext(email, exists, null, null);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AppFormField(
              name: 'email',
              hintText: 'Correo electrónico',
              validators: [
                FormBuilderValidators.required(errorText: 'Ingresa un email'),
                FormBuilderValidators.email(errorText: 'Email inválido'),
              ],
              onChanged: (val) {
                if (val != null) _emailController.text = val;
              },
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : MyButton(text: 'Continuar', onTap: _handleContinue),
          const SizedBox(height: 20),
          const _OrDivider(),
          const SizedBox(height: 20),
          _SocialButtons(onNext: widget.onNext),
          const SizedBox(height: 20),
          const _BottomLinks(),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('O', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  final void Function(
    String email,
    bool exists,
    String? photoUrl,
    AuthCredential? pendingCredential,
  )
  onNext;

  const _SocialButtons({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SquareTile(
      imagePath: 'assets/image/google.png', // Imagen de Google
      title: "Google",
      onTap: () async {
        try {
          print('🔍 Iniciando inicio de sesión con Google...');
          final userCredential = await AuthService().signInWithGoogle();

          if (userCredential != null) {
            final user = userCredential.user!;
            print('✅ Inicio de sesión exitoso con Google: ${user.email}');

            // Aquí puedes navegar directamente al home si deseas,
            // o manejarlo en AuthScreen (lo ideal)
            // Ejemplo opcional: llamar a onNext y forzar navegación a login
            // onNext(user.email!, true, user.photoURL, null);
          } else {
            print('⚠️ Inicio de sesión cancelado');
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'need-password') {
            final email = e.email!;
            final pendingCred = e.credential!;
            print('🔐 Se necesita contraseña para vincular: $email');
            // Llamamos al onNext para navegar a login y pasar datos
            onNext(email, true, null, pendingCred);
          } else {
            print('🚨 FirebaseAuthException: ${e.code}');
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error de autenticación'),
                content: Text(e.message ?? 'Ha ocurrido un error.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          print('❌ Error inesperado: $e');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Hubo un problema al intentar iniciar sesión con Google.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
} 

Future<String?> showPasswordDialog(BuildContext context, String email) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Vincular cuenta existente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ya existe una cuenta con el correo $email.'),
          TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Ingresa tu contraseña'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text('Vincular'),
        ),
      ],
    ),
  );
}


class _BottomLinks extends StatelessWidget {
  const _BottomLinks({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          // onTap: () => onNextNavigateToSignup(context),
          child: Text(
            '¿No tienes una cuenta? Regístrate',
            style: TextStyle(color: AppColors.pedidoListo, fontSize: 14),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '¿Has olvidado tu contraseña?',
          style: TextStyle(color: AppColors.pedidoListo, fontSize: 14),
        ),
      ],
    );
  }

  // void onNextNavigateToSignup(BuildContext context) {
  //   // si quieres también dar acceso directo a registro:
  //   onNext('', false, null, null);
  // }
}
