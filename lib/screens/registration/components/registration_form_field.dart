// lib/screens/registration/components/registration_form_field.dart
// Este es un ejemplo, puedes personalizarlo más.
import 'package:flutter/material.dart';

class RegistrationFormField extends StatelessWidget {
  final String labelText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController? controller; // Para campos como contraseña y confirmar contraseña

  const RegistrationFormField({
    Key? key,
    required this.labelText,
    this.prefixIcon,
    this.validator,
    this.onSaved,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          // Estilo heredado del inputDecorationTheme global
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}