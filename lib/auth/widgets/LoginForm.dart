// lib/features/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  final void Function(String email, String password)? onEmailLogin;
  final VoidCallback? onGoogleLogin;

  const LoginForm({super.key, this.onEmailLogin, this.onGoogleLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // Color de fondo del formulario
          borderRadius: BorderRadius.circular(12), // Bordes redondeados
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de correo electrónico
            FormBuilderTextField(
              key: const Key('usuario'), // 🔹 KEY para pruebas UI
              name: 'email',
              decoration: customInputDecoration('Correo electrónico'),
              style: const TextStyle(color: AppColors.background),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Campo de contraseña
            FormBuilderTextField(
              key: const Key('password'), // 🔹 KEY para pruebas UI
              name: 'password',
              decoration: customInputDecoration('Contraseña'),
              style: const TextStyle(color: AppColors.background),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(6),
              ]),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            // Botón de inicio de sesión
            ElevatedButton(
              key: const Key('btnLogin'), // 🔹 KEY para pruebas UI
              onPressed: () {
                if (_formKey.currentState!.saveAndValidate()) {
                  final values = _formKey.currentState!.value;
                  widget.onEmailLogin?.call(values['email'], values['password']);
                }
              },
              child: const Text('Iniciar sesión'),
            ),

            const SizedBox(height: 16),

            // Botón de inicio con Google
            OutlinedButton.icon(
              key: const Key('btnGoogle'), // 🔹 KEY para pruebas UI
              onPressed: widget.onGoogleLogin,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar con Google'),
            ),
          ],
        ),
      ),
    );
  }

  // Estilo de los campos de texto
  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.background),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryDark,
          width: 2,
        ),
      ),
    );
  }
}
