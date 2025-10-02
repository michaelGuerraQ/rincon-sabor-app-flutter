import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Una clase de servicio responsable de manejar operaciones relacionadas con la autenticación,
/// como el inicio de sesión, cierre de sesión y registro de usuarios.
///
/// Esta clase proporciona métodos para interactuar con los backends de autenticación
/// y gestionar el estado de autenticación del usuario dentro de la aplicación.
class AuthService {
  /// Una instancia de [FirebaseAuth] utilizada para manejar operaciones de autenticación
  /// como iniciar sesión, cerrar sesión y la gestión de usuarios dentro de la aplicación.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Inicia sesión con correo y contraseña.
  /// Retorna un [UserCredential] si es exitoso.
  /// Lanza [FirebaseAuthException] en caso de error.

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Inicia sesión en Firebase utilizando la autenticación de Google.
  ///
  /// Este método abre el flujo de inicio de sesión de Google. Si el usuario selecciona
  /// una cuenta y completa el proceso, se obtiene la autenticación de Google y se crea
  /// una credencial de Firebase con el token de acceso y el ID token proporcionados.
  /// Luego, se utiliza esta credencial para iniciar sesión en Firebase.
  ///
  /// Retorna un [UserCredential] si el inicio de sesión es exitoso.
  /// Si el usuario cancela el inicio de sesión de Google, retorna `null`.

  //   Future<UserCredential?> signInWithGoogle({String? passwordToLink}) async {
  //   try {
  //     // Iniciamos Google Sign-In
  //     print('🔍 Iniciando Google Sign-In... service');
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       print('⚠️ Google Sign-In cancelado por el usuario');
  //       return null;
  //     }

  //     // Obtención de credenciales
  //     print('🔍 Google Sign-In exitoso, obteniendo credenciales...');
  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Intentamos iniciar sesión con las credenciales obtenidas de Google
  //     print('🔍 Intentando iniciar sesión con las credenciales de Google...');
  //     final userCredential = await _auth.signInWithCredential(credential);
  //     print('✅ Google Sign-In OK service: ${userCredential.user!.email}');
  //     return userCredential;

  //   } on FirebaseAuthException catch (e) {
  //     print('🚨 FirebaseAuthException capturada: ${e.code}');
  //     if (e.code == 'account-exists-with-different-credential') {
  //       print('🔔 Cuenta existe con credenciales diferentes...');
  //       final email = e.email;
  //       final pendingCred = e.credential;

  //       // Verificamos los métodos de inicio de sesión para este correo
  //       print('🔍 Buscando métodos de inicio de sesión para $email...');
  //       final methods = await _auth.fetchSignInMethodsForEmail(email!);

  //       if (methods.contains('password')) {
  //         print('🔗 Cuenta asociada con contraseña, pidiendo la contraseña para vincular...');
  //         if (passwordToLink == null) {
  //           throw FirebaseAuthException(
  //             code: 'need-password',
  //             message: 'Se necesita la contraseña para vincular con Google.',
  //           );
  //         }

  //         // Iniciamos sesión con email/password para vincular
  //         print('🔍 Iniciando sesión con email y contraseña...');
  //         final emailUser = await _auth.signInWithEmailAndPassword(
  //           email: email,
  //           password: passwordToLink,
  //         );

  //         // Vinculamos las credenciales de Google con la cuenta de email
  //         print('🔗 Vinculando cuentas...');
  //         await emailUser.user!.linkWithCredential(pendingCred!);

  //         print('✅ Cuentas vinculadas con éxito');
  //         return await _auth.signInWithCredential(pendingCred);
  //       }

  //       // Si no se puede manejar el proveedor automáticamente
  //       print('🚫 No se puede manejar este proveedor automáticamente');
  //       throw FirebaseAuthException(
  //         code: 'cannot-handle-provider',
  //         message: 'No se puede manejar este proveedor automáticamente. Métodos existentes: $methods',
  //       );
  //     } else {
  //       print('🚨 Error desconocido en Google Sign-In: ${e.message}');
  //       rethrow;
  //     }
  //   }
  // }

  Future<UserCredential?> signInWithGoogle({String? passwordToLink}) async {
  try {
    print('🔍 Iniciando Google Sign-In...');

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      print('⚠️ El usuario canceló el inicio de sesión con Google');
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final email = googleUser.email;
    print('📧 Correo extraído de Google: $email');

    // Verificar si el correo ya tiene algún método de inicio de sesión asociado
    final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    print('🔍 Métodos encontrados para este correo: $methods');

    // Si el correo ya tiene un método de inicio de sesión (por ejemplo, email/password)
    if (methods.contains('password') && passwordToLink != null) {
      print('🔗 Vinculando cuenta de Google con la cuenta existente usando la contraseña...');
      // Si se pasa una contraseña, vincula la cuenta con la credencial
      final credentialEmailPassword = EmailAuthProvider.credential(
        email: email,
        password: passwordToLink,
      );

      // Vincula la cuenta actual con la de Google usando la contraseña proporcionada
      final userCredential = await FirebaseAuth.instance.currentUser!.linkWithCredential(credentialEmailPassword);
      print('✅ Cuenta de Google vinculada exitosamente a la cuenta existente');
      return userCredential;
    }

    // Si no hay conflicto, simplemente inicia sesión con Google
    print('🚀 Iniciando sesión con Google...');
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print('✅ Inicio de sesión con Google completado: ${userCredential.user?.email}');
    return userCredential;

  } on FirebaseAuthException catch (e) {
    print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
    if (e.code == 'provider-already-linked') {
      print('⚠️ Esta cuenta ya tiene Google vinculado');
    } else if (e.code == 'credential-already-in-use') {
      print('❌ La cuenta de Google ya está vinculada a otro usuario');
    }
    rethrow;
  } catch (e) {
    print('❌ Error inesperado al vincular cuenta: $e');
    rethrow;
  }
}


  /// Cierra la sesión del usuario tanto en Firebase como en Google.
  ///
  /// Este método cierra la sesión del usuario autenticado en Firebase y también
  /// cierra la sesión de la cuenta de Google utilizada para el inicio de sesión.
  ///
  /// Útil para asegurar que el usuario quede completamente desconectado de ambos servicios.

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  /// Verifica si un correo ya está registrado en Firebase Auth.
  /// Retorna `true` si el correo existe (es decir, ya hay al menos un método de login asociado),
  /// o `false` si no existe.
  Future<bool> isEmailRegistered(String email) async {
    try {
      print(
        'AuthService: isEmailRegistered() → consultando $email en Firebase...',
      );
      // ignore: deprecated_member_use
      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(
        email,
      );

      print('AuthService: métodos de ingreso para $email: $signInMethods');
      return signInMethods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      print(
        'AuthService: ERROR al llamar a fetchSignInMethodsForEmail: ${e.code} → ${e.message}',
      );

      // Por si Firebase arroja algún error (p. ej. formato inválido de email)
      // Podemos volver a lanzar o retornar false demostrando que no existe o informar al usuario.
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Obtiene el usuario actualmente autenticado en Firebase.
  ///
  /// Retorna una instancia de [User] si hay un usuario autenticado,
  /// o `null` si no hay ningún usuario autenticado en la aplicación.

  User? get currentUser => _auth.currentUser;
}
