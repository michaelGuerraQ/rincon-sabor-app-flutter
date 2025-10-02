import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rincon_sabor_flutter/auth/components/BlurContainer.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/auth/widgets/AppFormField.dart';
import 'package:rincon_sabor_flutter/auth/widgets/my_button.dart';
import 'package:rincon_sabor_flutter/core/guards/authGate.dart';

class SignupPage extends StatefulWidget {
  final String email;
  const SignupPage({super.key, required this.email});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerAndGoHome() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final email = widget.email;
    final pwd = _passwordCtrl.text.trim();

    try {
      await _authService.createUserWithEmail(email, pwd);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Authgate()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlurContainer(
          child: _SignupFormContent(
            formKey: _formKey,
            email: widget.email,
            passwordController: _passwordCtrl,
            confirmController: _confirmCtrl,
            onSubmit: _registerAndGoHome,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SignupFormContent extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final String email;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onSubmit;

  const _SignupFormContent({
    required this.formKey,
    required this.email,
    required this.passwordController,
    required this.confirmController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Registrarse como', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(email, style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 30),
          AppFormField(
            name: 'password',
            hintText: 'Contraseña',
            obscureText: true,
            validators: [
              FormBuilderValidators.required(errorText: 'Ingresa una contraseña'),
              FormBuilderValidators.minLength(6, errorText: 'Mínimo 6 caracteres'),
            ],
            onChanged: (val) => passwordController.text = val ?? '',
          ),
          const SizedBox(height: 10),
          AppFormField(
            name: 'confirm_password',
            hintText: 'Confirmar contraseña',
            obscureText: true,
            validators: [
              FormBuilderValidators.required(errorText: 'Repite la contraseña'),
              (val) {
                if (val != passwordController.text) return 'No coinciden';
                return null;
              },
            ],
            onChanged: (val) => confirmController.text = val ?? '',
          ),
          const SizedBox(height: 30),
          MyButton(onTap: onSubmit, text: 'Aceptar y continuar'),
        ],
      ),
    );
  }
}