import 'package:flutter/material.dart';

Route createRoute(Widget page, {int tipo = 0}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

      switch (tipo) {
        case 1:
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
                .animate(curved),
            child: child,
          );
        case 2:
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: curved,
              child: child,
            ),
          );
        case 3:
          return RotationTransition(
            turns: Tween(begin: 0.9, end: 1.0).animate(curved),
            child: child,
          );
        default:
          return FadeTransition(opacity: curved, child: child);
      }
    },
    transitionDuration: Duration(milliseconds: 600),
  );
}
