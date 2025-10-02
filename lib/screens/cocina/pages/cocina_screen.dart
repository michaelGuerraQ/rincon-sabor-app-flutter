import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/cocina/components/pedido_card.dart';
import 'package:rincon_sabor_flutter/screens/cocina/pages/pedido_detail_screen.dart';

class CocinaScreen extends StatefulWidget {
  const CocinaScreen({super.key});

  @override
  State<CocinaScreen> createState() => _CocinaScreen();
}

class _CocinaScreen extends State<CocinaScreen> {
  final authService = AuthService();
  List<Pedido> pedidos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final pedidosData = await PedidosService.fetchPedidosActivos();
      if (kDebugMode) {
        print('Pedidos retornados: $pedidosData');
      }
      setState(() {
        pedidos = pedidosData;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener pedidos: $e');
      }
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPedidos() async {
    await _loadPedidos();
  }

  /// Actualiza el estado de un pedido específico.
  /// Si el pedido no existe, no hace nada.
  void _updatePedidoStatus(String pedidoCodigo, String nuevoEstado) {
    setState(() {
      final pedidoIndex = pedidos.indexWhere((p) => p.pedidoCodigo == pedidoCodigo);
      if (pedidoIndex != -1) {
        // Crear una nueva instancia del pedido con el estado actualizado
        final pedidoActual = pedidos[pedidoIndex];
        final pedidoActualizado = Pedido(
          pedidoCodigo: pedidoActual.pedidoCodigo,
          pedidoFechaHora: pedidoActual.pedidoFechaHora,
          pedidoTotal: pedidoActual.pedidoTotal,
          pedidoEstado: nuevoEstado,
          mesaCodigo: pedidoActual.mesaCodigo,
          mesaNumero: pedidoActual.mesaNumero,
          detalles: pedidoActual.detalles,
        );
        pedidos[pedidoIndex] = pedidoActualizado;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D3748),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4A5568),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cocina',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          /// Contenedor que muestra el número de pedidos activos
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A5568),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: AppColors.secondary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${pedidos.length} pedidos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          /// Botón para cerrar sesión
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4A5568),
                width: 1,
              ),
            ),
            // child: IconButton(
            //   icon: Icon(
            //     Icons.refresh,
            //     color: AppColors.secondary,
            //   ),
            //   onPressed: _refreshPedidos,
            // ),
            child: IconButton(
                      onPressed: () async {
                        await authService.signOut();
                      },
                      icon: Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 20,
                      ),
                      tooltip: 'Cerrar Sesión',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    /// Muestra un indicador de carga mientras se obtienen los pedidos.
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando pedidos...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar pedidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshPedidos,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    /// Si no hay pedidos, muestra un estado vacío.
    if (pedidos.isEmpty) {
      return _buildEmptyState();
    }

    /// Muestra la lista de pedidos activos.
    return RefreshIndicator(
      onRefresh: _refreshPedidos,
      color: AppColors.secondary,
      backgroundColor: const Color(0xFF2D3748),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PedidoCard(
                pedido: pedido,
                onTap: () => _navigateToPedidoDetail(pedido),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye el estado vacío que se muestra cuando no hay pedidos activos.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay pedidos activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los nuevos pedidos aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshPedidos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 16),
                SizedBox(width: 8),
                Text('Actualizar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navega a la pantalla de detalles del pedido.
  void _navigateToPedidoDetail(Pedido pedido) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PedidoDetailScreen(
          pedido: pedido,
          onStatusChanged: _updatePedidoStatus,
        ),
      ),
    );
  }
}
