// /**
//  * Clase Config
//  *
//  * Esta clase se encarga de centralizar la configuración global del proyecto, permitiendo gestionar
//  * parámetros críticos que pueden variar según el entorno de ejecución de la aplicación. Su implementación
//  * busca facilitar la adaptación a distintos escenarios (por ejemplo, web, móvil o escritorio) sin necesidad 
//  * de modificar el código fuente principal.
//  *
//  * Propiedad:
//  *   - apiUrl: Propiedad estática que retorna la URL de la API. Su valor se determina de acuerdo al entorno
//  *     en el que se esté ejecutando la aplicación:
//  *       • En un entorno web (Flutter Web), se retorna la URL local 'http://localhost:8080', debido a las 
//  *         limitaciones en el manejo de variables de entorno en este contexto.
//  *       • En otros entornos (móvil, escritorio, etc.), se intenta obtener la URL desde las variables de entorno 
//  *         mediante el paquete 'flutter_dotenv'. Si no se ha definido la variable 'API_URL', se utiliza por defecto 
//  *         'http://localhost:8080'.
//  *
//  * Ejemplo de uso:
//  *   String url = Config.apiUrl;
//  *
//  * Este diseño modular y centralizado permite una configuración flexible y segura, optimizando el mantenimiento 
//  * y la escalabilidad del proyecto.
//  */

// import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// // Crea una **clase llamada `Config`** para guardar configuraciones generales que se puedan usar en cualquier parte del proyecto.
// class Config {
//   static String get apiUrl {
//     //      `kIsWeb` es una constante que detecta si tu app **está corriendo en el navegador (Flutter Web)**.
//     // - Si es así, **devuelve directamente** `'http://localhost:8080'`, porque en web a veces las variables de entorno no funcionan.
//     if (kIsWeb) {
//       return 'http://backend-rincon-sabor.onrender.com';
//     }
//     return dotenv.env['API_URL'] ?? 'http://192.168.10.12:8080';
//   }
// }


import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  /// Siempre obtiene la URL de la API desde la variable de entorno `API_URL`.
  /// Si no existe, retorna el string que decidas poner como fallback.
  static String? get apiUrl {
    return dotenv.env['API_URL'];
  }
}
