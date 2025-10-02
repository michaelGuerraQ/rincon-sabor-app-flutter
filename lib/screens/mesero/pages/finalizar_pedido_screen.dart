import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';

class FinalizarPedidoScreen extends StatelessWidget {
  final Mesa mesa;
  final String pedidoCodigo;
  final List<DetallePedido> pedidoActual;

  const FinalizarPedidoScreen({
    super.key,
    required this.mesa,
    required this.pedidoCodigo,
    required this.pedidoActual,
  });

  double get total => pedidoActual.fold(0.0, (sum, d) => sum + d.subtotal);

  Color _colorPorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'preparando':
        return Colors.blue;
      case 'listo':
        return Colors.green;
      case 'servido':
        return Colors.purple;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa ${mesa.numero} – Finalizar Pedido $pedidoCodigo'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Resumen de Pedido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Código de Mesa: ${mesa.codigo}'),
                subtitle: Text(
                  'Ítems: ${pedidoActual.length}    Total: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),

          // Lista detallada
          Expanded(
            child: ListView.separated(
              itemCount: pedidoActual.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, i) {
                final d = pedidoActual[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // Imagen o placeholder
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child:
                        d.producto.imageUrl != null
                            ? Image.network(
                              d.producto.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.fastfood, color: Colors.grey),
                            ),
                  ),
                  title: Text(
                    d.producto.platos,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${d.cantidad}'),
                      if (d.notas.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Nota: ${d.notas}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${d.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colorPorEstado(d.estado),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botón de confirmar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Confirmar Finalización',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  // llamada al servicio para finalizar
                  final ok = await PedidosService.finalizarPedido(pedidoCodigo);
                  final msg =
                      ok
                          ? 'Pedido $pedidoCodigo finalizado'
                          : 'Error finalizando pedido';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                  if (ok) Navigator.popUntil(context, (r) => r.isFirst);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
