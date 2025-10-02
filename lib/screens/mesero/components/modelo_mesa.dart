import 'package:flutter/material.dart';

class ModeloMesa extends StatelessWidget {
  final Color color;
  final String label;

  const ModeloMesa({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, 
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: const Color(0xFFFFFFFF), width: 2),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
            textAlign: TextAlign.center, // Opcional: centra el texto dentro del ancho
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
