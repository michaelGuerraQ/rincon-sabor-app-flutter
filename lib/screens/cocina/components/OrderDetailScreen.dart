// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Se podría usar para formatear fechas
// import '../../../core/theme/app_color.dart'; // Colores personalizados de la app
// import '../../../core/models/Pedido.dart'; // Modelo de pedido (aunque no se usa directamente aquí)
// import '../../../core/models/DetallePedido.dart'; // Modelo de detalle (igual, no se usa directamente)
// import 'order_card.dart'; // Clase que contiene la lógica de íconos y colores por estado

// // Pantalla de detalles del pedido
// class OrderDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> order; // Pedido recibido como un mapa
//   final Function(String, String) onStatusChange; // Callback para actualizar el estado de un detalle

//   const OrderDetailScreen({super.key, required this.order, required this.onStatusChange});

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// // Estado de la pantalla de detalles
// class _OrderDetailScreenState extends State<OrderDetailScreen> with StatusHelper {
//   // Conjunto de detalles seleccionados para cambiar estado en lote
//   final Set<String> _selectedDetails = {};

//   @override
//   Widget build(BuildContext context) {
//     // Extrae la lista de detalles del pedido, si no hay, se usa lista vacía
//     final detalles = widget.order['Detalles'] as List<dynamic>? ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         // Título con el número de pedido
//         title: Text(
//           'Detalles del Pedido #${widget.order['PedidoCodigo'] ?? 'Desconocido'}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.gradientPrimary, // Color personalizado
//         foregroundColor: AppColors.white, // Color del texto del AppBar
//         actions: [
//           // Botón para aplicar cambios masivos si hay ítems seleccionados
//           if (_selectedDetails.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.check),
//               onPressed: () => _showBatchUpdateDialog(),
//             ),
//         ],
//       ),
//       backgroundColor: AppColors.black, // Fondo de la pantalla
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           // Tarjeta con información general del pedido
//           Card(
//             color: AppColors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Fila con ícono del estado del pedido y código de pedido
//                   Row(
//                     children: [
//                       Tooltip(
//                         message: widget.order['PedidoEstado'] ?? 'Desconocido',
//                         child: Icon(
//                           getStatusIcon(widget.order['PedidoEstado']),
//                           color: getStatusColor(widget.order['PedidoEstado']),
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Pedido #${widget.order['PedidoCodigo'] ?? 'Desconocido'} - Mesa ${widget.order['MesaNumero'] ?? 'N/A'}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                             color: AppColors.black,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   // Estado del pedido con color respectivo
//                   Text(
//                     'Estado: ${widget.order['PedidoEstado'] ?? 'Desconocido'}',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: getStatusColor(widget.order['PedidoEstado']),
//                     ),
//                   ),
//                   // Fecha y hora del pedido
//                   Text(
//                     'Fecha y Hora: ${widget.order['PedidoFechaHora'] ?? 'N/A'}',
//                     style: const TextStyle(fontSize: 16, color: AppColors.black),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Tarjeta con lista de detalles del pedido
//           Card(
//             color: AppColors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Detalles del Pedido',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: AppColors.black,
//                     ),
//                   ),
//                   // Se mapea cada detalle a una checkbox para selección múltiple
//                   ...detalles.map((detalle) => CheckboxListTile(
//                     // Título con cantidad x producto
//                     title: Text(
//                       '${detalle['detallePedidoCantidad']?.toString() ?? '0'} x ${detalle['Producto']?['MenuPlatos'] ?? 'Ítem desconocido'}',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     // Subtítulo con estado y notas si existen
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Estado: ${detalle['detallePedidoEstado'] ?? 'Desconocido'}'),
//                         if (detalle['detallePedidoNotas'] != null && (detalle['detallePedidoNotas'] as String).isNotEmpty)
//                           Text('Notas: ${detalle['detallePedidoNotas']}'),
//                       ],
//                     ),
//                     // Valor de la checkbox (seleccionado o no)
//                     value: _selectedDetails.contains(detalle['detallePedidoCodigo']),
//                     onChanged: (bool? value) {
//                       setState(() {
//                         // Agrega o quita el código del detalle a la selección
//                         if (value == true) {
//                           _selectedDetails.add(detalle['detallePedidoCodigo'] ?? '');
//                         } else {
//                           _selectedDetails.remove(detalle['detallePedidoCodigo']);
//                         }
//                       });
//                     },
//                     // Ícono del estado del detalle
//                     secondary: Icon(
//                       getStatusIcon(detalle['detallePedidoEstado']),
//                       color: getStatusColor(detalle['detallePedidoEstado']),
//                     ),
//                   )),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Muestra el diálogo para actualizar estado masivamente
//   void _showBatchUpdateDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Actualizar Estado'),
//         content: const Text('Selecciona el nuevo estado para los detalles seleccionados:'),
//         actions: [
//           // Botones con los distintos estados posibles
//           TextButton(
//             onPressed: () => _batchUpdate('Preparando'),
//             child: const Text('Preparando'),
//           ),
//           TextButton(
//             onPressed: () => _batchUpdate('Listo'),
//             child: const Text('Listo'),
//           ),
//           TextButton(
//             onPressed: () => _batchUpdate('Servido'),
//             child: const Text('Servido'),
//           ),
//           TextButton(
//             onPressed: () => _batchUpdate('Cancelado'),
//             child: const Text('Cancelado'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Ejecuta el cambio de estado en los detalles seleccionados
//   Future<void> _batchUpdate(String newStatus) async {
//     for (var code in _selectedDetails) {
//       // Llama a la función para cambiar el estado del detalle
//       await widget.onStatusChange(code, newStatus);
//     }
//     setState(() {
//       // Limpia la selección después de aplicar los cambios
//       _selectedDetails.clear();
//     });
//     Navigator.pop(context); // Cierra el diálogo
//   }
// }
