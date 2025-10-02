import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';


class ButtonsSelector extends StatefulWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color color;

  const ButtonsSelector({super.key, required this.texto, required this.onPressed, this.color = AppColors.success});

  @override
  State<ButtonsSelector> createState() => _ButtonsSelectorState();
}

class _ButtonsSelectorState extends State<ButtonsSelector> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
      ),
      child: Text(
        widget.texto,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

