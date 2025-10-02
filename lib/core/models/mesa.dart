enum EstadoMesa { disponible, ocupada, esperando, mantenimiento }

class Mesa {
  final String codigo;
  final String numero;
  final EstadoMesa estado;

  Mesa({required this.codigo, required this.numero, required this.estado});

  factory Mesa.fromJson(Map<String, dynamic> json) {
    EstadoMesa estado;

    switch (json['MesaEstado']) {
      case 'ocupada':
        estado = EstadoMesa.ocupada;
        break;
      case 'esperando':
        estado = EstadoMesa.esperando;
        break;
      case 'mantenimiento':
        estado = EstadoMesa.mantenimiento;
        break;
      case 'disponible':
      default:
        estado = EstadoMesa.disponible;
        break;
    }

    return Mesa(
      codigo: json['MesaCodigo'],
      numero: json['MesaNumero'],
      estado: estado,
    );
  }

  // Colores para cada estado
  int get colorValue {
    switch (estado) {
      case EstadoMesa.disponible:
        return 0xFF4CAF50; // Verde
      case EstadoMesa.ocupada:
        return 0xFFF44336; // Rojo
      case EstadoMesa.esperando:
        return 0xFFFF9800; // Naranja
      case EstadoMesa.mantenimiento:
        return 0xFF9E9E9E; // Gris
    }
  }

  String get estadoLabel {
    switch (estado) {
      case EstadoMesa.disponible:
        return 'Disponible';
      case EstadoMesa.ocupada:
        return 'Ocupada';
      case EstadoMesa.esperando:
        return 'Esperando';
      case EstadoMesa.mantenimiento:
        return 'Mantenimiento';
    }
  }
}
