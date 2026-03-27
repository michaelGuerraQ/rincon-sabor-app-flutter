import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppFormField extends StatelessWidget {
  final String name;
  final String hintText;
  final bool obscureText;
  final String? initialValue;
  final List<FormFieldValidator<String>>? validators;
  final void Function(String?)? onChanged;

  const AppFormField({
    Key? key,
    required this.name,
    required this.hintText,
    this.obscureText = false,
    this.initialValue,
    this.validators,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      key: Key('field_$name'), //  Clave dinámica: única por campo
      name: name,
      initialValue: initialValue,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      validator: validators == null
          ? null
          : FormBuilderValidators.compose(validators!),
      onChanged: onChanged,
    );
  }
}
