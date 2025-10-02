// import 'package:flutter/material.dart';
// import '../../../core/theme/app_color.dart'; // Importa colores personalizados
// import 'order_card.dart'; // Importa StatusHelper para obtener íconos por estado

// // Widget sin estado que muestra un resumen de los estados de los pedidos en forma de chips
// class SummaryChips extends StatelessWidget with StatusHelper {
//   // Cantidad de pedidos por cada estado
//   final int pendingCount;
//   final int inProgressCount;
//   final int readyCount;
//   final int servedCount;
//   final int canceledCount;

//   // Constructor con parámetros requeridos
//   const SummaryChips({
//     super.key,
//     required this.pendingCount,
//     required this.inProgressCount,
//     required this.readyCount,
//     required this.servedCount,
//     required this.canceledCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       alignment: WrapAlignment.center, // Centra los chips horizontalmente
//       spacing: 8.0, // Espacio horizontal entre chips
//       children: [
//         // Un chip por cada estado, con color e ícono correspondiente
//         _buildChip('Pendiente', pendingCount, AppColors.red),
//         _buildChip('Preparando', inProgressCount, AppColors.colorSecondary),
//         _buildChip('Listo', readyCount, AppColors.colorPrimary),
//         _buildChip('Servido', servedCount, AppColors.green),
//         _buildChip('Cancelado', canceledCount, AppColors.gray),
//       ],
//     );
//   }

//   // Método privado para construir cada chip con su icono, color y cantidad
//   Widget _buildChip(String label, int count, Color color) {
//     return Chip(
//       avatar: Icon(
//         getStatusIcon(label), // Usa el mixin StatusHelper para obtener el ícono por estado
//         color: AppColors.white, // Ícono blanco sobre fondo coloreado
//         size: 18,
//       ),
//       label: Text(
//         '$label: $count', // Texto con nombre del estado y su cantidad
//         style: const TextStyle(color: AppColors.white), // Texto blanco
//       ),
//       backgroundColor: color.withOpacity(0.7), // Color de fondo con opacidad
//     );
//   }
// }
