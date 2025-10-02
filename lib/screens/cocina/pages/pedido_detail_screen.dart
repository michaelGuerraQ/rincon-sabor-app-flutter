import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/services/mesas_service.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class PedidoDetailScreen extends StatefulWidget {
  final Pedido pedido;
  final Function(String, String) onStatusChanged;

  const PedidoDetailScreen({
    super.key,
    required this.pedido,
    required this.onStatusChanged,
  });

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  late Pedido currentPedido;
  Set<String> updatingDetalles = {};

  @override
  void initState() {
    super.initState();
    currentPedido = widget.pedido;
  }
  /// esta función actualiza el estado de un detalle del pedido
  /// y maneja la lógica de actualización del pedido y la mesa
  /// evitando reentradas y mostrando mensajes de éxito o error
  /// según corresponda
  Future<void> _updateDetalleStatus(
    String detalleCodigo,
    String newStatus,
  ) async {
    // Evitamos reentradas
    ///esto quiere decir que si ya estamos actualizando este detalle,
    ///no volvemos a llamar a esta función hasta que termine la actualización
    if (updatingDetalles.contains(detalleCodigo)) return;

    // Indicamos que estamos actualizando este detalle
    setState(() => updatingDetalles.add(detalleCodigo));

    try {
      // 1) Actualizar el estado del detalle en el backend
      final detalleOk = await PedidosService.actualizarEstadoDetallePedido(
        detallePedidoCodigo: detalleCodigo,
        nuevoEstado: newStatus,
      );
      if (!detalleOk) throw 'No se pudo actualizar detalle';

      // 2) Si todo va bien, comprobamos localmente si ya todos los detalles están "Listo"
      final copia = List.of(currentPedido.detalles);
      final idx = copia.indexWhere(
        (d) => d.detallePedidoCodigo == detalleCodigo,
      );
      if (idx != -1) copia[idx].estado = newStatus;

      final todosListos = copia.every((d) => d.estado.toLowerCase() == 'listo');
      final algunPendiente = copia.any(
        (d) => d.estado.toLowerCase() == 'pendiente',
      );

      // 3) Sincronizar pedido y mesa según estado
      bool pedidoOk = false, mesaOk = false;
      if (todosListos && currentPedido.pedidoEstado.toLowerCase() != 'listo') {
        // a) todos listos → pedido "Listo" y mesa "disponible"
        pedidoOk = await PedidosService.actualizarEstadoPedido(
          pedidoCodigo: currentPedido.pedidoCodigo,
          nuevoEstado: 'Listo',
        );
        if (pedidoOk) {
          print(
            'Pedido listo. Actualizando mesa ${currentPedido.mesaCodigo} → disponible',
          );
          mesaOk = await MesaService.actualizarEstadoMesa(
            mesaCodigo: currentPedido.mesaCodigo,
            nuevoEstado: EstadoMesa.ocupada,
          );
          if (!mesaOk) print('Error al actualizar mesa a disponible');
        }
      } else if (algunPendiente &&
          currentPedido.pedidoEstado.toLowerCase() != 'pendiente') {
        // b) hay al menos un pendiente → pedido "Pendiente" y mesa "esperando"
        pedidoOk = await PedidosService.actualizarEstadoPedido(
          pedidoCodigo: currentPedido.pedidoCodigo,
          nuevoEstado: 'Pendiente',
        );
        if (pedidoOk) {
          print(
            'Pedido pendiente. Actualizando mesa ${currentPedido.mesaCodigo} → esperando',
          );
          mesaOk = await MesaService.actualizarEstadoMesa(
            mesaCodigo: currentPedido.mesaCodigo,
            nuevoEstado: EstadoMesa.esperando,
          );
          if (!mesaOk) print('Error al actualizar mesa a esperando');
        }
      }

      // 4) Actualizar estado local y snackbar
      setState(() {
        final detalleIndex = currentPedido.detalles.indexWhere(
          (d) => d.detallePedidoCodigo == detalleCodigo,
        );
        if (detalleIndex != -1) {
          currentPedido.detalles[detalleIndex].estado = newStatus;
        }
        if (pedidoOk) {
          currentPedido.pedidoEstado = todosListos ? 'Listo' : 'Pendiente';
          widget.onStatusChanged(
            currentPedido.pedidoCodigo,
            currentPedido.pedidoEstado,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a: $newStatus'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      // Quitamos el loading de este detalle
      setState(() => updatingDetalles.remove(detalleCodigo));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D3748),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pedido #${currentPedido.pedidoCodigo}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPedidoHeader(),
            const SizedBox(height: 20),
            _buildProgressSection(),
            const SizedBox(height: 20),
            _buildItemsList(),
            const SizedBox(height: 20),
            _buildPedidoSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoHeader() {
    final estadoActual = currentPedido.estadoEnum;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A5568),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${currentPedido.pedidoCodigo}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mesa ${currentPedido.mesaNumero}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentPedido.timeAgo,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Color(estadoActual.colorValue).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(estadoActual.colorValue).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  estadoActual.label,
                  style: TextStyle(
                    color: Color(estadoActual.colorValue),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progreso = currentPedido.progresoPedido;
    final detallesListos =
        currentPedido.detalles
            .where((d) => d.estado.toLowerCase() == 'listo')
            .length;
    final totalDetalles = currentPedido.detalles.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A5568),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso del Pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$detallesListos/$totalDetalles listos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: const Color(0xFF4A5568),
              valueColor: AlwaysStoppedAnimation<Color>(
                progreso == 1.0 ? AppColors.success : AppColors.secondary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progreso * 100).toInt()}% completado',
            style: TextStyle(
              fontSize: 12, 
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
  /// este widget construye la lista de artículos del pedido
  /// mostrando cada detalle con su estado y opciones de cambio de estado
  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A5568),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artículos del Pedido (${currentPedido.totalItems})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...currentPedido.detalles.map(
            (detalle) => _buildDetalleItem(detalle),
          ),
        ],
      ),
    );
  }
  /// este widget construye cada detalle del pedido
  /// mostrando información del producto, cantidad, estado y opciones de cambio de estado
  /// y maneja el estado de actualización para evitar múltiples solicitudes
  /// de cambio de estado al mismo tiempo
  Widget _buildDetalleItem(DetallePedido detalle) {
    final estadoDetalle = detalle.estadoEnum;
    final isUpdating = updatingDetalles.contains(detalle.detallePedidoCodigo);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(estadoDetalle.colorValue).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${detalle.cantidad}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detalle.producto.platos,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (detalle.producto.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        detalle.producto.descripcion,
                        style: TextStyle(
                          fontSize: 12, 
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                    if (detalle.notas.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFF9800), // Orange with alpha
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Nota: ${detalle.notas}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(estadoDetalle.colorValue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(estadoDetalle.colorValue).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      estadoDetalle.label,
                      style: TextStyle(
                        color: Color(estadoDetalle.colorValue),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${detalle.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          /// Cambiar Estado
          /// Este widget permite cambiar el estado del detalle del pedido
          Text(
            'Cambiar Estado:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 8),
          /// Si está actualizando, muestra un indicador de carga
          /// de lo contrario, muestra los estados disponibles para seleccionar
          if (isUpdating)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            )
          else
          /// Muestra los estados disponibles para seleccionar
          /// y permite al usuario seleccionar uno para cambiar el estado del detalle
          /// los estados los trae desde el enum EstadoDetalle
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: EstadoDetalle.values
              /// excluye los estados "cancelado" y "servido"
              /// para evitar que se puedan seleccionar
                  .where((estado) =>
                      estado != EstadoDetalle.servido)
                  .map((estado) {
                /// Verifica si el estado actual del detalle es igual al estado del enum
                /// si es así, lo marca como seleccionado
                final isSelected =
                    estado.label.toLowerCase() == detalle.estado.toLowerCase();
                return GestureDetector(
                  /// Al hacer tap en un estado, actualiza el estado del detalle
                  /// llamando a la función _updateDetalleStatus
                  onTap: () => _updateDetalleStatus(
                    detalle.detallePedidoCodigo,
                    estado.label,
                  ),
                  /// Si el estado está seleccionado, cambia el color del contenedor
                  /// de lo contrario, lo muestra con un color más claro
                  child: Container(
                    // Padding y decoración del contenedor del estado
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(estado.colorValue)
                          : Color(estado.colorValue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(estado.colorValue),
                        width: isSelected ? 0 : 1,
                      ),
                    ),
                    child: Text(
                      estado.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Color(estado.colorValue),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPedidoSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A5568),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'S/ ${currentPedido.pedidoTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A202C),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4A5568),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline, 
                  color: AppColors.textDisabled, 
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pedido realizado: ${_formatDateTime(currentPedido.pedidoFechaHora)}',
                    style: TextStyle(
                      fontSize: 14, 
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} a las ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
