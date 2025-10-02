import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DropdownRolUsuario extends StatelessWidget {
  final String nombreCampo;

  const DropdownRolUsuario({super.key, this.nombreCampo = 'rol'});

  @override
  Widget build(BuildContext context) {
    final roles = ['admin', 'cocinero', 'mesero'];

    return FormBuilderDropdown<String>(
      name: nombreCampo,
      decoration: InputDecoration(
        labelText: 'Rol',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
      ),
      validator: FormBuilderValidators.required(),
      items: roles.map(
        (rol) => DropdownMenuItem(value: rol, child: Text(rol)),
      ).toList(),
    );
  }
}
