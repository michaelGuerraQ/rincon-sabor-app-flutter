import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// convertir el estado del pedido a un enum
    /// esto permite manejar los estados de manera más segura y legible
    /// además de facilitar la asignación de colores y etiquetas
    final estadoEnum = pedido.estadoEnum;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748), // Fondo dark
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4A5568), // Borde sutil
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${pedido.pedidoCodigo} - ${pedido.pedidoEstado}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Texto blanco
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.table_restaurant,
                              size: 16,
                              color: Color(0xFFA0AEC0), // Gris claro
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Mesa ${pedido.mesaNumero}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFA0AEC0), // Gris claro
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFFA0AEC0), // Gris claro
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pedido.timeAgo,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFA0AEC0), // Gris claro
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
                      color: Color(estadoEnum.colorValue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(estadoEnum.colorValue).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      estadoEnum.label,
                      style: TextStyle(
                        color: Color(estadoEnum.colorValue),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A202C), // Fondo más oscuro
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A5568),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Artículos (${pedido.totalItems})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // Texto blanco
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...pedido.detalles.take(3).map((detalle) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4299E1), // Azul original
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    '${detalle.cantidad}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  detalle.producto.platos,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFA0AEC0), // Gris claro
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (pedido.detalles.length > 3)
                      Text(
                        '+${pedido.detalles.length - 3} más...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096), // Gris medio
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${pedido.pedidoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Texto blanco
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x604299E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4299E1).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver detalles',
                          style: TextStyle(
                            color: Color(0xFF4299E1),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF4299E1),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
