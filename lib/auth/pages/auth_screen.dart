import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/auth/components/HeaderBackIcon.dart';
import 'package:rincon_sabor_flutter/auth/components/TextPresentation.dart';
import 'package:rincon_sabor_flutter/auth/components/background_image.dart';
import 'package:rincon_sabor_flutter/auth/pages/screens/login.dart';
import 'package:rincon_sabor_flutter/auth/pages/screens/signup.dart';
import 'package:rincon_sabor_flutter/auth/pages/screens/welcome.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _currentIndex = 0;
  String _email = '';
  String? _photoUrl;
  AuthCredential? _pendingCred;

  void _goTo(
    int index, {
    String? email,
    String? photoUrl,
    AuthCredential? pending,
  }) {
    setState(() {
      _currentIndex = index;
      if (email != null) _email = email;
      if (photoUrl != null) _photoUrl = photoUrl;
      if (pending != null) _pendingCred = pending;
    });
  }

  String get _screenTitle {
    switch (_currentIndex) {
      case 0:
        return "Bienvenido";
      case 1:
        return "Registrarse";
      case 2:
        return "Iniciar sesión";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      WelcomePage(
        onNext: (email, exists, photoUrl, pending) {
          // guardamos el email y demás, y navegamos
          if (exists) {
            _goTo(2, email: email, photoUrl: photoUrl, pending: pending);
          } else {
            _goTo(1, email: email);
          }
        },
      ),
      SignupPage(email: _email),
      LoginContent(
        email: _email,
        photoUrl: _photoUrl,
        pendingCredential: _pendingCred,
      ),
    ];
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          BackgroundImage(),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Headerbackicon(
                    onPressed: () {
                      if (_currentIndex > 0) _goTo(0);
                    },
                  ),
                  SizedBox(height: 20),
                  Textpresentation(text: _screenTitle, fontSize: 40),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // screens[_currentIndex],
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_currentIndex),
                      child: screens[_currentIndex],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
