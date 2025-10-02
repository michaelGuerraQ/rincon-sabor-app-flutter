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

  Color getColorPorEstado() {
    switch (mesa.estado) {
      case EstadoMesa.disponible:
        return AppColors.mesaDisponible;
      case EstadoMesa.ocupada:
        return AppColors.mesaOcupada;
      case EstadoMesa.mantenimiento:
        return AppColors.mesaMantenimiento;
      case EstadoMesa.esperando:
        return AppColors.mesaEsperando;
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    // CORRECCIÓN 1: Validar mantenimiento
    if (mesa.estado == EstadoMesa.mantenimiento) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesa en mantenimiento')),
      );
      return;
    }

    // CORRECCIÓN 2: Preparar valores por defecto
    List<DetallePedido> detalles = [];
    String? pedidoCodigo;

    // CORRECCIÓN 3: Solo llamamos al servicio si LA MESA NO está disponible
    if (mesa.estado != EstadoMesa.disponible) {
      try {
        final pedidos = await PedidosService.fetchPedidosPorMesa(mesa.codigo);

        if (pedidos.isNotEmpty) {
          final pedido = pedidos.first;

          // CORRECCIÓN 3.a: Si el pedido ya está servido o todos sus detalles servidos
          if (pedido.pedidoEstado.toLowerCase() == 'servido' ||
              pedido.detalles.every((d) => d.isServido)) {
            // Actualizar la mesa a disponible en el servidor
            final ok = await MesaService.actualizarEstadoMesa(
              mesaCodigo: mesa.codigo,
              nuevoEstado: EstadoMesa.disponible,
            );

            // CORRECCIÓN: Verificar mounted antes de usar context
            if (!context.mounted) return;

            if (ok) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Mesa liberada')),
                );
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Error interno al liberar mesa')),
                );
            }
            return; // No dejamos navegar a selección de platos
          }

          // CORRECCIÓN 3.b: Si no está servido, cargamos detalles para la edición
          detalles = pedido.detalles;
          pedidoCodigo = pedido.pedidoCodigo;
        }
      } catch (e) {
        // CORRECCIÓN: Manejar errores y verificar mounted
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pedidos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        // Continuar con valores por defecto
      }
    }

    // CORRECCIÓN 4: Verificar mounted antes de navegar
    if (!context.mounted) return;

    // Navegar pasándole ALWAYS la mesa y los valores
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionPlatosScreen(
          mesa: mesa,
          initialDetalles: detalles, // Lista vacía o con pedidos
          pedidoCodigo: pedidoCodigo, // null si no existe aún
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = getColorPorEstado();

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Mesa ${mesa.numero}',
          style: const TextStyle(color: AppColors.background),
        ),
      ),
    );
  }
}
