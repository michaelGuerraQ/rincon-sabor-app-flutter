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
      ) onNext;

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      key: const Key('welcome_container'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AppFormField(
              key: const Key('field_email'),
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
              ? const CircularProgressIndicator(
            key: Key('progress_welcome'),
            color: Colors.white,
          )
              : MyButton(
            key: const Key('btn_continuar'),
            text: 'Continuar',
            onTap: _handleContinue,
          ),
          const SizedBox(height: 20),
          const _OrDivider(),
          const SizedBox(height: 20),
          _SocialButtons(
            key: const Key('social_buttons'),
            onNext: widget.onNext,
          ),
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
      key: const Key('divider_or'),
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
      ) onNext;

  const _SocialButtons({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SquareTile(
      key: const Key('btn_google'),
      imagePath: 'assets/image/google.png', // Imagen de Google
      title: "Google",
      onTap: () async {
        try {
          print('🔍 Iniciando inicio de sesión con Google...');
          final userCredential = await AuthService().signInWithGoogle();

          if (userCredential != null) {
            final user = userCredential.user!;
            print('✅ Inicio de sesión exitoso con Google: ${user.email}');
          } else {
            print('⚠️ Inicio de sesión cancelado');
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'need-password') {
            final email = e.email!;
            final pendingCred = e.credential!;
            print('🔐 Se necesita contraseña para vincular: $email');
            onNext(email, true, null, pendingCred);
          } else {
            print('🚨 FirebaseAuthException: ${e.code}');
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                key: const Key('dialog_google_error'),
                title: const Text('Error de autenticación'),
                content: Text(e.message ?? 'Ha ocurrido un error.'),
                actions: [
                  TextButton(
                    key: const Key('btn_google_error_ok'),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
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
              key: const Key('dialog_google_unexpected'),
              title: const Text('Error'),
              content: const Text(
                'Hubo un problema al intentar iniciar sesión con Google.',
              ),
              actions: [
                TextButton(
                  key: const Key('btn_google_unexpected_ok'),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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
      key: const Key('dialog_password'),
      title: Text('Vincular cuenta existente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ya existe una cuenta con el correo $email.'),
          TextField(
            key: const Key('txt_password_dialog'),
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Ingresa tu contraseña'),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('btn_cancelar_vincular'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          key: const Key('btn_vincular'),
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Vincular'),
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
      key: const Key('bottom_links'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: const Key('link_registro'),
          child: Text(
            '¿No tienes una cuenta? Regístrate',
            style: TextStyle(color: AppColors.pedidoListo, fontSize: 14),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '¿Has olvidado tu contraseña?',
          key: const Key('link_olvido_password'),
          style: TextStyle(color: AppColors.pedidoListo, fontSize: 14),
        ),
      ],
    );
  }
}
