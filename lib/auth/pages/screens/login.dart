import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../components/BlurContainer.dart';
import '../../services/auth_service.dart';
import '../../widgets/AppFormField.dart';
import '../../widgets/my_button.dart';

class LoginContent extends StatefulWidget {
  final String email;
  final String? photoUrl;
  final AuthCredential? pendingCredential;

  const LoginContent({
    super.key,
    required this.email,
    this.photoUrl,
    this.pendingCredential,
  });

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    // 1) mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
    );

    try {
      final cred = await _authService.signInWithEmail(
        widget.email,
        _passwordCtrl.text,
      );
      if (widget.pendingCredential != null) {
        await cred.user!.linkWithCredential(widget.pendingCredential!);
      }
    } on FirebaseAuthException catch (e) {
      // mostrar error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      // 2) ¡cerrar siempre el loader!
      if (mounted) Navigator.pop(context);
      // 3) ya no navegues aquí: AuthGate reaccionará al cambio de sesión
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlurContainer(
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          widget.photoUrl != null
                              ? NetworkImage(widget.photoUrl!)
                              : const AssetImage('assets/image/google.png')
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppFormField(
                  name: 'password',
                  hintText: 'Contraseña',
                  obscureText: true,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Ingresa una contraseña',
                    ),
                    FormBuilderValidators.minLength(
                      6,
                      errorText: 'Mínimo 6 caracteres',
                    ),
                  ],
                  onChanged: (val) => _passwordCtrl.text = val ?? '',
                ),
                const SizedBox(height: 24),
                MyButton(text: 'Iniciar sesión', onTap: _signIn),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
