import 'package:flutter/material.dart';

class Textpresentation extends StatelessWidget {

  final String text;
  final double fontSize;
  const Textpresentation({super.key, required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}