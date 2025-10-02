import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class Custombutton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  // Constructor
  const Custombutton({
    super.key,
    required this.text,
    required this.onPressed,
    });

  @override
  State<Custombutton> createState() => _CustombuttonState();
}

class _CustombuttonState extends State<Custombutton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: AppColors.pedidoListo, width: 2),
          ),
          elevation: 0,
        ),
        child: Text(widget.text),
      ),
    );
  }
}