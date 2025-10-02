import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rincon_sabor_flutter/core/guards/authGate.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await dotenv.load(fileName: "assets/.env");
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rincón Sabor',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        // otros locales si quieres…
      ],
      // theme: ThemeData(
      //   fontFamily: 'Poppins',
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
        
      // ),
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.dark, 
      home: Authgate(),
    );
  }
}
