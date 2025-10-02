import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/services/mesas_service.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';
import '../models/menu.dart';
import '../services/menu_service.dart';
import '../services/categoria_service.dart';

class SeleccionPlatosViewModel extends ChangeNotifier {
  List<Menu> menus = [];
  List<Categoria> categorias = [];
  Map<String, bool> visibles = {};
  List<DetallePedido> _pedido = [];
  bool loading = true;
  String searchText = '';
  String? pedidoCodigoActual;

  // Getter público para pedido
  List<DetallePedido> get pedido => _pedido;

  // Setter que asegura que la lista sea mutable
  set pedido(List<DetallePedido> value) {
    _pedido = List<DetallePedido>.from(value);
    notifyListeners();
  }

  Future<void> loadData() async {
    loading = true;
    notifyListeners();

    try {
      menus = await MenuService.obtenerMenus();
      categorias = await CategoriaService.obtenerCategorias();

      // Inicializar todas las categorías como visibles (expandidas)
      // Mantener el estado actual si ya existe
      for (var categoria in categorias) {
        if (!visibles.containsKey(categoria.nombre)) {
          visibles[categoria.nombre] = true;
        }
      }
    } catch (e) {
      // print('Error loading data: $e');
    }

    loading = false;
    notifyListeners();
  }

  void addToPedido(Menu m) {
    // sólo busco un detalle igual que esté en estado pendiente
    final idx = _pedido.indexWhere(
      (d) => d.producto.codigo == m.codigo && !d.isListo,
    );
    if (idx >= 0) {
      // incrementa cantidad en el detalle pendiente
      print('lo que estoy mandando: ${_pedido[idx].cantidad + 1} ');
      _pedido[idx] = _pedido[idx].copyWith(cantidad: _pedido[idx].cantidad + 1);
    } else {
      _pedido.add(
        DetallePedido(
          detallePedidoCodigo: '',
          cantidad: 1,
          estado: 'pendiente',
          notas: '',
          producto: m,
        ),
      );
    }
    notifyListeners();
  }

  void removeOne(DetallePedido d) {
    final idx = _pedido.indexOf(d);
    if (idx < 0) return;
    if (_pedido[idx].cantidad > 1) {
      _pedido[idx] = _pedido[idx].copyWith(cantidad: _pedido[idx].cantidad - 1);
    } else {
      _pedido.removeAt(idx);
    }
    notifyListeners();
  }

  void updateNota(DetallePedido detalle, String nuevaNota) {
    final idx = _pedido.indexOf(detalle);
    if (idx < 0) return;
    _pedido[idx] = _pedido[idx].copyWith(notas: nuevaNota);
    notifyListeners();
  }

  void toggleCategoria(String nombre) {
    visibles[nombre] = !(visibles[nombre] ?? false);
    notifyListeners();
  }

  void updateSearch(String text) {
    searchText = text;
    notifyListeners();
  }

  bool get allListo => _pedido.isNotEmpty && _pedido.every((d) => d.isListo);

  bool get tienePendientes =>
      _pedido.any((d) => d.estadoEnum == EstadoDetalle.pendiente);

  double get totalPedido =>
      _pedido.fold(0.0, (sum, detalle) => sum + detalle.subtotal);

  int get totalItems =>
      _pedido.fold(0, (sum, detalle) => sum + detalle.cantidad);

  Map<String, dynamic> toOrderBody(String mesaNumero) {
    return {
      'mesa': mesaNumero,
      'detalles': _pedido.map((d) => d.toJson()).toList(),
    };
  }

  Future<bool> cancelarPedido(Mesa mesa, BuildContext context) async {
    final codigo = pedidoCodigoActual;
    if (codigo == null) return false;

    final eliminado = await PedidosService.borrarPedido(codigo);
    if (!eliminado) {
      _mostrarError(context, 'Error al cancelar el pedido');
      return false;
    }

    final mesaLiberada = await MesaService.actualizarEstadoMesa(
      mesaCodigo: mesa.codigo,
      nuevoEstado: EstadoMesa.disponible,
    );

    if (!mesaLiberada) {
      _mostrarError(context, 'Error al liberar la mesa');
      return false;
    }

    return true;
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  /// Procesa el pedido actual y actualiza el estado de la mesa.
  /// Retorna un mensaje de error si ocurre algún problema, o null si todo es correcto
  /// @param mesaCodigo Código de la mesa a la que se le procesará el pedido
  /// @return String? Mensaje de error o null si todo es correcto
  Future<String?> procesarPedido(String mesaCodigo) async {
    try {
      if (pedidoCodigoActual == null) {
        // print('Creando nuevo pedido para mesa $mesaCodigo');
        // print('lO DATOS QUE ESTOY MANDANDO: ${_pedido.map((d) => d.toCreationMap()).toList()}');
        await PedidosService.crearPedido(
          mesaCodigo: mesaCodigo,
          detalles: _pedido,
        );
      } else if (_pedido.isEmpty) {
        await PedidosService.borrarPedido(pedidoCodigoActual!);
        pedidoCodigoActual = null;
      } else {
        final detallesPayload = _pedido.map((d) => d.toCreationMap()).toList();
        // 2) Imprimo en consola para depurar
        print('🔍 Payload detalles para actualizar pedido: $detallesPayload');
        await PedidosService.actualizarDetallesPedido(
          pedidoCodigo: pedidoCodigoActual!,
          detalles: _pedido.map((d) => d.toCreationMap()).toList(),
        );

        // Actualizar también el estado del pedido según el estado de sus detalles
        final todosListos = _pedido.every(
          (d) => d.estado.toLowerCase() == 'listo',
        );
        final nuevoEstadoPedido = todosListos ? 'Listo' : 'Pendiente';
        final okPedido = await PedidosService.actualizarEstadoPedido(
          pedidoCodigo: pedidoCodigoActual!,
          nuevoEstado: nuevoEstadoPedido,
        );
        if (!okPedido) return 'Error al actualizar el estado del pedido';
      }

      // Determinar nuevo estado mesa
      late EstadoMesa nuevoEstado;
      if (_pedido.isEmpty) {
        nuevoEstado = EstadoMesa.disponible;
      } else if (_pedido.any((d) => d.estado.toLowerCase() == 'pendiente')) {
        nuevoEstado = EstadoMesa.esperando;
      } else if (_pedido.every((d) => d.estado.toLowerCase() == 'listo')) {
        nuevoEstado = EstadoMesa.ocupada;
      } else if (_pedido.any((d) => d.estado.toLowerCase() == 'servido')) {
        nuevoEstado = EstadoMesa.disponible;
      } else {
        nuevoEstado = EstadoMesa.ocupada;
      }

      final okMesa = await MesaService.actualizarEstadoMesa(
        mesaCodigo: mesaCodigo,
        nuevoEstado: nuevoEstado,
      );

      if (!okMesa) return 'Error al actualizar el estado de la mesa';
      return null;
    } catch (e) {
      return 'Error al procesar pedido: $e';
    }
  }

  void notify() => notifyListeners();
}
