import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/services/mesas_service.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';
import 'package:rincon_sabor_flutter/core/services/socket_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/mesero/components/leyenda_mesas.dart';
import 'package:rincon_sabor_flutter/screens/mesero/components/mesa_card.dart';
import 'package:rincon_sabor_flutter/screens/mesero/pages/seleccion_platos_screen.dart';

class SeleccionMesaScreen extends StatefulWidget {
  const SeleccionMesaScreen({super.key});

  @override
  State<SeleccionMesaScreen> createState() => _SeleccionMesaScreenState();
}

class _SeleccionMesaScreenState extends State<SeleccionMesaScreen> {
  List<Mesa> mesas = [];
  bool isLoading = true;
  String? errorMessage;
  final authService = AuthService();

  static const Color _darkBackground = Color(0xFF1A202C);
  static const Color _darkSurface = Color(0xFF2D3748);
  static const Color _darkSurfaceVariant = Color(0xFF4A5568);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarMesas();
      SocketService.initSocket(() async {
        if (mounted) {
          await _cargarMesas();
        }
      });
    });
  }

  @override
  void dispose() {
    SocketService.dispose();
    super.dispose();
  }

  Future<void> _cargarMesas() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final nuevasMesas = await MesaService.obtenerMesas();
      if (!mounted) return;
      setState(() {
        mesas = nuevasMesas;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _mostrarMensaje(String mensaje, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onMesaSelected(Mesa mesa) async {
    if (mesa.estado == EstadoMesa.mantenimiento) {
      _mostrarMensaje('Esta mesa está en mantenimiento', AppColors.warning);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Container(
        color: _darkBackground.withOpacity(0.8),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
        ),
      ),
    );

    try {
      List<DetallePedido> detallesExistentes = [];
      String? pedidoCodigo;

      if (mesa.estado == EstadoMesa.esperando || mesa.estado == EstadoMesa.ocupada) {
        final pedidosDeMesa = await PedidosService.fetchPedidosPorMesa(mesa.codigo);

        final pedidoActivo = pedidosDeMesa.where((pedido) {
          final estado = pedido.pedidoEstado.toLowerCase();
          return estado != 'finalizado' && estado != 'cancelado' && estado != 'servido';
        }).firstOrNull;

        if (pedidoActivo != null) {
          detallesExistentes = pedidoActivo.detalles;
          pedidoCodigo = pedidoActivo.pedidoCodigo;

          if (mounted) {
            _mostrarMensaje('Cargando pedido existente: ${pedidoActivo.pedidoCodigo}', AppColors.secondary);
          }
        } else {
          if (mounted) {
            _mostrarMensaje('No se encontró pedido activo para esta mesa', AppColors.warning);
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeleccionPlatosScreen(
              mesa: mesa,
              initialDetalles: detallesExistentes,
              pedidoCodigo: pedidoCodigo,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _mostrarMensaje('Error al cargar pedidos: $e', AppColors.error);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeleccionPlatosScreen(
              mesa: mesa,
              initialDetalles: const [],
              pedidoCodigo: null,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Seleccionar Mesa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white, letterSpacing: 0.5)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: _darkSurfaceVariant, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              onPressed: _cargarMesas,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              tooltip: 'Actualizar mesas',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: _darkSurfaceVariant, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await authService.signOut();
                  if (mounted) navigator.popUntil((route) => route.isFirst);
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(SnackBar(
                      content: Text('Error al cerrar sesión: $e', style: const TextStyle(color: Colors.white)),
                      backgroundColor: AppColors.error,
                    ));
                  }
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Cerrar sesión',
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _darkSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            const Text('Cargando mesas...', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              const Text('Error al cargar mesas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _cargarMesas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    if (mesas.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _cargarMesas,
      color: AppColors.primary,
      backgroundColor: _darkSurface,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mesas del Restaurante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${mesas.length} mesas disponibles', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const LeyendaMesas(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: mesas.length,
                itemBuilder: (context, index) {
                  final mesa = mesas[index];
                  return MesaCard(mesa: mesa, onTap: () => _onMesaSelected(mesa));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _darkSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.table_restaurant_rounded, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            const Text('No hay mesas disponibles', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const Text(
              'Las mesas aparecerán aquí cuando estén configuradas en el sistema',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _cargarMesas,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
