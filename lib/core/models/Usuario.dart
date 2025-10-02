import 'package:intl/intl.dart';

class Usuario {
  final String usuarioCodigo;
  final String usuarioNombre;
  final String usuarioEmail;
  final String usuarioDireccion;
  final String usuarioTelefono;
  final String usuarioFechaRegistrosinFormatear;
  String usuarioEstado;
  final String usuarioRol;

  String get usuarioFechaRegistro {
    try {
      final date = DateTime.parse(usuarioFechaRegistrosinFormatear);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return usuarioFechaRegistrosinFormatear; 
    }
  }

  Usuario({
    required this.usuarioCodigo,
    required this.usuarioNombre,
    required this.usuarioEmail,
    required this.usuarioDireccion,
    required this.usuarioTelefono,
    required this.usuarioFechaRegistrosinFormatear,
    required this.usuarioEstado,
    required this.usuarioRol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuarioCodigo: json['UsuarioCodigo'],
      usuarioNombre: json['UsuarioNombre'],
      usuarioEmail: json['UsuarioEmail'],
      usuarioDireccion: json['UsuarioDireccion'] ?? '',
      usuarioTelefono: json['UsuarioTelefono'] ?? '',
      usuarioFechaRegistrosinFormatear: json['UsuarioFechaRegistro'],
      usuarioEstado: json['UsuarioEstado'],
      usuarioRol: json['UsuarioRol'],
    );
  }
}
