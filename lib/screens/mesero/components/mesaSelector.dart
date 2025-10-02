import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/services/mesas_service.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/mesero/pages/seleccion_platos_screen.dart';

class MesaSelector extends StatelessWidget {
  final Mesa mesa;

  const MesaSelector({super.key, required this.mesa});

  Color _getColorPorEstado() {
    switch (mesa.estado) {
      case EstadoMesa.disponible:
        return AppColors.mesaDisponible;
      case EstadoMesa.ocupada:
        return AppColors.mesaOcupada; // Color para ocupada
      case EstadoMesa.mantenimiento:
        return AppColors.mesaMantenimiento; // Color para inactiva
      case EstadoMesa.esperando:
        return AppColors.mesaEsperando;
    }
  }

  void _handleTap(BuildContext context) async {
    // 1) Validar mantenimiento
    if (mesa.estado == EstadoMesa.mantenimiento) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mesa en mantenimiento')));
      return;
    }
    // 2) Preparar valores por defecto
    List<DetallePedido> detalles = [];
    String? pedidoCodigo;

    // 3) Solo llamamos al servicio si LA MESA NO está “disponible”
    if (mesa.estado != EstadoMesa.disponible) {
      final pedidos = await PedidosService.fetchPedidosPorMesa(mesa.codigo);
      if (pedidos.isNotEmpty) {
        final pedido = pedidos.first;
        // 3.a) Si el pedido ya está servido (o todos sus detalles servidos)
        if (pedido.pedidoEstado.toLowerCase() == 'servido' ||
            pedido.detalles.every((d) => d.isServido)) {
          // actualizo la mesa a disponible en el servidor
          final ok = await MesaService.actualizarEstadoMesa(
            mesaCodigo: mesa.codigo,
            nuevoEstado: EstadoMesa.disponible,
          );
          if (ok) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Mesa liberada')));
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Error interno al liberar mesa')));
          }
          return; // no dejamos navegar a selección de platos
        }

        // 3.b) si no está servido cargamos detalles para la edición
        detalles = pedido.detalles;
        pedidoCodigo = pedido.pedidoCodigo;
      }
    }


    // 4) Navegar pasándole ALWAYS la mesa y los valores
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SeleccionPlatosScreen(
              mesa: mesa,
              initialDetalles: detalles, // lista vacía o con pedidos
              pedidoCodigo: pedidoCodigo, // null si no existe aún
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _getColorPorEstado();

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "Mesa ${mesa.numero}",
          style: const TextStyle(color: AppColors.background),
        ),
      ),
    );
  }
}
