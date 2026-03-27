import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/view_model/seleccion_platos_view_model.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/mesero/components/item_pedido_widget.dart';
import 'package:rincon_sabor_flutter/screens/mesero/pages/finalizar_pedido_screen.dart';

class PedidoFab extends StatefulWidget {
  final Mesa mesa;
  final GlobalKey fabKey;

  const PedidoFab({super.key, required this.mesa, required this.fabKey});

  @override
  State<PedidoFab> createState() => _PedidoFabState();
}

class _PedidoFabState extends State<PedidoFab> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SeleccionPlatosViewModel>();

    return Container(
      key: const Key('pedido_fab_container'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.2),
            blurRadius: 30,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        key: widget.fabKey,
        onPressed: () => _showPedidoDialog(context, vm),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: const Key('pedido_icon_container'),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart_rounded, size: 20),
            ),
            if (vm.pedido.isNotEmpty)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  key: const Key('pedido_badge'),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.error, Color(0xFFE53E3E)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${vm.totalItems}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        label: Container(
          key: const Key('pedido_label_container'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            vm.pedido.isEmpty
                ? 'Pedido'
                : 'S/.${vm.totalPedido.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _editarNotaDialog(BuildContext context, String initial) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        key: const Key('dialog_editar_nota'),
        backgroundColor: const Color(0xFF2D3748),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Agregar nota', style: TextStyle(color: Colors.white)),
        content: TextField(
          key: const Key('nota_textfield'),
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ej: sin cebolla, extra queso...',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancelar_nota'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('btn_guardar_nota'),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPedidoDialog(
      BuildContext context, SeleccionPlatosViewModel vm) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: vm,
        child: Consumer<SeleccionPlatosViewModel>(
          builder: (context, vmConsumer, _) {
            return _buildPedidoContenido(ctx, vmConsumer);
          },
        ),
      ),
    );
  }

  Widget _buildPedidoContenido(BuildContext ctx, SeleccionPlatosViewModel vm) {
    return Container(
      key: const Key('pedido_bottomsheet'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Pedido Actual',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                key: const Key('btn_close_pedido'),
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          const SizedBox(height: 10),
          vm.pedido.isEmpty
              ? const Text(
            'Tu pedido está vacío',
            key: Key('pedido_vacio_text'),
            style: TextStyle(color: Colors.white70),
          )
              : ListView.builder(
            key: const Key('pedido_lista_items'),
            shrinkWrap: true,
            itemCount: vm.pedido.length,
            itemBuilder: (_, i) => ItemPedidoWidget(
              detalle: vm.pedido[i],
              onEditarNota: () async {
                final nota =
                await _editarNotaDialog(ctx, vm.pedido[i].notas);
                if (nota != null) vm.updateNota(vm.pedido[i], nota);
              },
              onQuitar: () => vm.removeOne(vm.pedido[i]),
            ),
          ),
          const SizedBox(height: 20),
          if (vm.pedido.isNotEmpty)
            ElevatedButton(
              key: const Key('btn_enviar_cocina'),
              onPressed: _isProcessing
                  ? null
                  : () async {
                setState(() => _isProcessing = true);
                Navigator.pop(ctx);
                await Future.delayed(const Duration(seconds: 1));
                setState(() => _isProcessing = false);
              },
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Enviar a Cocina'),
            ),
        ],
      ),
    );
  }
}
