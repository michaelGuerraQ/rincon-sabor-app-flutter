enum OrderStatus {
  pending('Pendiente', 0xFFFF9800),
  preparing('Preparando', 0xFF2196F3),
  ready('Listo', 0xFF4CAF50),
  delivered('Entregado', 0xFF9E9E9E);

  const OrderStatus(this.label, this.colorValue);
  final String label;
  final int colorValue;
}

class OrderItem {
  final String name;
  final int quantity;
  final String notes;

  OrderItem({
    required this.name,
    required this.quantity,
    this.notes = '',
  });
}

class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime orderTime;
  OrderStatus status;
  final String tableNumber;
  final double total;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.orderTime,
    required this.status,
    required this.tableNumber,
    required this.total,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(orderTime);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
  }
}
