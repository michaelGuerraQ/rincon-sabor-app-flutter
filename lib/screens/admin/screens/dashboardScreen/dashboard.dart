import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rincon_sabor_flutter/auth/services/auth_service.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/models/weekLyGain_model.dart' hide Mesa;
import 'package:rincon_sabor_flutter/core/services/graficodata_service.dart';
import 'package:rincon_sabor_flutter/core/services/mesas_service.dart';
import 'package:rincon_sabor_flutter/core/services/pedidos_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/dashboardScreen/widgets/graficos.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/dashboardScreen/widgets/predicciones_ventas.dart';
import 'package:rincon_sabor_flutter/screens/cocina/pages/cocina_screen.dart';
import 'package:rincon_sabor_flutter/screens/mesero/pages/seleccion_mesa_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final authService = AuthService();
  int anio = DateTime.now().year;
  int mes = DateTime.now().month;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getMonthName(int mes) {
    const nombres = [
      '', // para que 1=Ene, 2=Feb
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return nombres[mes];
  }

  // Map<String, dynamic> _getDashboardStats() {
  //   return {
  //     'ventasHoy': 2450.50,
  //     'pedidosHoy': 45,
  //     'mesasOcupadas': 12,
  //     'totalMesas': 20,
  //     'gananciaMes': 45780.30,
  //     'clientesHoy': 78,
  //   };
  // }

  // List<Map<String, dynamic>> _getTableData() {
  //   return [
  //     {'numero': 1, 'estado': 'disponible'},
  //     {'numero': 2, 'estado': 'ocupada'},
  //     {'numero': 3, 'estado': 'ocupada'},
  //     {'numero': 4, 'estado': 'esperando'},
  //     {'numero': 5, 'estado': 'disponible'},
  //     {'numero': 6, 'estado': 'ocupada'},
  //     {'numero': 7, 'estado': 'mantenimiento'},
  //     {'numero': 8, 'estado': 'disponible'},
  //   ];
  // }

  // List<Map<String, dynamic>> _getRecentOrders() {
  //   return [
  //     {'id': '#001', 'mesa': 2, 'total': 85.50, 'estado': 'preparando'},
  //     {'id': '#002', 'mesa': 4, 'total': 42.30, 'estado': 'listo'},
  //     {'id': '#003', 'mesa': 6, 'total': 156.80, 'estado': 'pendiente'},
  //     {'id': '#004', 'mesa': 1, 'total': 67.20, 'estado': 'servido'},
  //   ];
  // }

  // Color _getStatusColor(String estado) {
  //   switch (estado) {
  //     case 'disponible':
  //       return AppColors.mesaDisponible;
  //     case 'ocupada':
  //       return AppColors.mesaOcupada;
  //     case 'esperando':
  //       return AppColors.mesaEsperando;
  //     case 'mantenimiento':
  //       return AppColors.mesaMantenimiento;
  //     case 'pendiente':
  //       return AppColors.pedidoPendiente;
  //     case 'preparando':
  //       return AppColors.pedidoPreparando;
  //     case 'listo':
  //       return AppColors.pedidoListo;
  //     case 'servido':
  //       return AppColors.pedidoServido;
  //     default:
  //       return AppColors.primary;
  //   }
  // }

  Color _getColorFromEstado(EstadoMesa estado) {
    switch (estado) {
      case EstadoMesa.disponible:
        return const Color(0xFF4CAF50); // Verde
      case EstadoMesa.ocupada:
        return const Color(0xFFF44336); // Rojo
      case EstadoMesa.esperando:
        return const Color(0xFFFF9800); // Naranja
      case EstadoMesa.mantenimiento:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  void _navigateToCocina() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CocinaScreen()),
    );
  }

  void _navigateToMesero() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeleccionMesaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final stats = _getDashboardStats();
    // final tables = _getTableData();
    // final orders = _getRecentOrders();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Informe del Restaurante',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Botón de cerrar sesión en el header
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha:0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => _showLogoutDialog(context),
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
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildNavigationButton(
                      title: 'Cocina',
                      subtitle: 'Gestionar pedidos',
                      icon: Icons.restaurant_menu,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warning,
                          AppColors.warning.withValues(alpha:0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap:
                          _navigateToCocina, 
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNavigationButton(
                      title: 'Mesero',
                      subtitle: 'Atender mesas',
                      icon: Icons.person_outline,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.info,
                          AppColors.info.withValues(alpha:0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap:
                          _navigateToMesero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const PrediccionVentasWidget(),
              const SizedBox(height: 20),


              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  FutureBuilder<VentasHoy>(
                    future: GraficodataService.fetchVentasHoy(),
                    builder: (context, snapshot) {
                      String ventasValue;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        ventasValue = '...';
                      } else if (snapshot.hasError) {
                        ventasValue = 'err';
                      } else if (snapshot.hasData) {
                        ventasValue = 'S/. ${snapshot.data!.totalVentas.toStringAsFixed(2)}';
                      } else {
                        ventasValue = 'S/. 0.00';
                      }
                      return _buildStatsCard(
                        'Ventas Hoy',
                        ventasValue,
                        Icons.attach_money,
                        AppColors.success,
                      );
                    },
                  ),
                  FutureBuilder<List<PedidoHoy>>(
                    future: GraficodataService.fetchPedidosHoy(),
                    builder: (context, snapshot) {
                      String pedidosValue;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        pedidosValue = '...';
                      } else if (snapshot.hasError) {
                        pedidosValue = 'err';
                      } else if (snapshot.hasData) {
                        pedidosValue = '${snapshot.data!.length}';
                      } else {
                        pedidosValue = '0';
                      }
                      return _buildStatsCard(
                        'Pedidos Hoy',
                        pedidosValue,
                        Icons.receipt_long,
                        AppColors.info,
                      );
                    },
                  ),
                  FutureBuilder<MesasDisponibles>(
                    future: GraficodataService.fetchMesasDisponibles(),
                    builder: (context, snapshot) {
                      String mesasValue;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        mesasValue = '...';
                      } else if (snapshot.hasError) {
                        mesasValue = 'err';
                      } else if (snapshot.hasData) {
                        mesasValue = snapshot.data!.summary;
                      } else {
                        mesasValue = '0';
                      }
                      return _buildStatsCard(
                        'Mesas Disponibles',
                        mesasValue,
                        Icons.table_restaurant,
                        AppColors.info,
                      );
                    },
                  ),
                  FutureBuilder<GananciasMesActual>(
                    future: GraficodataService.fetchGananciasMesActual(),
                    builder: (context, snapshot) {
                      String gananciaValue;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        gananciaValue = '...';
                      } else if (snapshot.hasError) {
                        gananciaValue = 'err';
                      } else if (snapshot.hasData) {
                        gananciaValue = 'S/. ${snapshot.data!.totalGanancias.toStringAsFixed(2)}';
                      } else {
                        gananciaValue = 'S/. 0.00';
                      }
                      return _buildStatsCard(
                        'Ganancia Mes',
                        gananciaValue,
                        Icons.trending_up,
                        AppColors.success,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes: $mes / Año: $anio',
                    style: const TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showMonthPicker(
                        context: context,
                        initialDate: DateTime(anio, mes),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          anio = picked.year;
                          mes = picked.month;
                        });
                      }
                    },
                    child: const Text('Elegir Mes/Año'),
                  ),
                ],
              ),
              const SizedBox(height: 10),


              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: FutureBuilder<List<WeeklyGainByMonth>>(
                      future: GraficodataService.fetchGananciasSemanalesPorMes(
                        anio: anio,
                        mes: mes,
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError || snap.data == null) {
                          return const Center(
                            child: Text('Error al cargar datos'),
                          );
                        }
                        final semanal = snap.data!;
                        final salesData =
                            semanal
                                .map(
                                  (w) => SalesData(
                                    'Semana ${w.semanaDelMes}',
                                    w.ganancias,
                                  ),
                                )
                                .toList();
                        return SalesChart(data: salesData);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ganancias de los mesas del $anio',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: FutureBuilder<List<MonthlyGain>>(
                          future: GraficodataService.fetchGananciasMensuales(
                            anio: anio,
                          ),
                          builder: (context, snap) {
                            if (snap.connectionState != ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snap.hasError || snap.data == null) {
                              return const Center(
                                child: Text('Error al cargar datos'),
                              );
                            }

                            final mensual = snap.data!;
                            final data =
                                mensual.map((m) {
                                  final nombreMes = _getMonthName(m.mes);
                                  return EarningsData(nombreMes, m.ganancias);
                                }).toList();

                            return EarningsChart(data: data);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Sección de mesas y pedidos recientes (DATOS FICTICIOS)
              FutureBuilder<List<Mesa>>(
                future: MesaService.obtenerMesas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No se pudieron cargar las mesas'));
                  }
                  final tables = snapshot.data!;
                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado de Mesas',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: tables.length,
                            itemBuilder: (context, index) {
                              final table = tables[index];
                              final color = _getColorFromEstado(table.estado);
                              return Container(
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    table.numero,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            children: [
                              _buildLegendItem('Disponible', _getColorFromEstado(EstadoMesa.disponible)),
                              _buildLegendItem('Ocupada', _getColorFromEstado(EstadoMesa.ocupada)),
                              _buildLegendItem('Esperando', _getColorFromEstado(EstadoMesa.esperando)),
                              _buildLegendItem('Mantenimiento', _getColorFromEstado(EstadoMesa.mantenimiento)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Sección de pedidos recientes (TU CÓDIGO ORIGINAL)
              FutureBuilder<List<Pedido>>(
                future: PedidosService.fetchPedidosActivos(),
                builder: (context, AsyncSnapshot<List<Pedido>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay pedidos recientes'));
                  }

                  final orders = snapshot.data!
                    ..sort((a, b) => b.pedidoFechaHora.compareTo(a.pedidoFechaHora)); // Ordenar de más reciente a más antiguo
                  final limitedOrders = orders.take(5).toList(); // Tomar solo los primeros 5

                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pedidos Recientes',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      'Últimos ${limitedOrders.length} pedidos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Navegando a pedidos completos...'),
                                    ),
                                  );
                                },
                                child: const Text('Ver todos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: limitedOrders.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final order = limitedOrders[index];
                              final statusColor = Color(order.estadoEnum.colorValue);
                              final formattedDateTime = DateFormat('dd/MM/yyyy hh:mm a').format(order.pedidoFechaHora);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                order.pedidoCodigo,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).textTheme.titleMedium?.color,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  order.estadoEnum.label,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mesa ${order.mesaNumero}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).textTheme.bodySmall?.color,
                                            ),
                                          ),
                                          Text(
                                            '${order.detalles.length} items • $formattedDateTime',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context).textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'S/. ${order.pedidoTotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 80, // ✅ Reducido de 100 a 80
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(
                  12,
                ), // ✅ Reducido de 16 a 12
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.25),
                    blurRadius: 8, // ✅ Reducido de 12 a 8
                    offset: const Offset(0, 4), // ✅ Reducido de 6 a 4
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // ✅ Padding más compacto
                    child: Row(
                      // ✅ Cambiado de Column a Row para diseño horizontal
                      children: [
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 28, // ✅ Reducido de 32 a 28
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2), // ✅ Reducido de 8 a 2
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11, // ✅ Reducido de 12 a 11
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();     // solo cierra el diálogo
              await authService.signOut();     // ejecuta el logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      );
    },
  );
}


}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
