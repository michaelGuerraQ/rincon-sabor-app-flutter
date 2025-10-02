import 'dart:ui';
import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final double widthFactor;
  final double sigmaX;
  final double sigmaY;
  final double opacity;

  const BlurContainer({
    super.key,
    required this.child,
    this.heightFactor = 0.63,
    this.widthFactor = 0.9,
    this.sigmaX = 5.0,
    this.sigmaY = 5.0,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width * widthFactor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
            child: Container(
              width: ancho,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:opacity),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha:0.20),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
