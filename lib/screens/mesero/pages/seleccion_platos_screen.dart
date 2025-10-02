import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/models/DetallePedido.dart';
import 'package:rincon_sabor_flutter/core/view_model/seleccion_platos_view_model.dart';
import 'package:rincon_sabor_flutter/core/models/mesa.dart';
import 'package:rincon_sabor_flutter/core/services/mesas_service.dart';
import 'package:rincon_sabor_flutter/core/services/socket_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/widgets/input_search.dart';
import 'package:rincon_sabor_flutter/screens/mesero/components/menu_category_section.dart';
import 'package:rincon_sabor_flutter/screens/mesero/components/pedido_fab.dart';


class SeleccionPlatosScreen extends StatefulWidget {
  final Mesa mesa;
  final List<DetallePedido> initialDetalles;
  final String? pedidoCodigo;

  const SeleccionPlatosScreen({
    super.key,
    required this.mesa,
    this.initialDetalles = const [],
    this.pedidoCodigo,
  });

  @override
  State<SeleccionPlatosScreen> createState() => _SeleccionPlatosScreenState();
}

class _SeleccionPlatosScreenState extends State<SeleccionPlatosScreen>
    with TickerProviderStateMixin {
  final GlobalKey _fabKey = GlobalKey();
  late SeleccionPlatosViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  // Colores del tema dark
  static const Color _darkBackground = Color(0xFF1A202C);
  static const Color _darkSurface = Color(0xFF2D3748);
  static const Color _darkSurfaceVariant = Color(0xFF4A5568);

  void _runAddBubble(Offset start) {
    final overlay = Overlay.of(context);
    final renderBox = _fabKey.currentContext!.findRenderObject() as RenderBox;
    final end = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final animation = Tween<Offset>(
      begin: start,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final entry = OverlayEntry(
      builder: (_) {
        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) => Positioned(
            left: animation.value.dx,
            top: animation.value.dy,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.restaurant,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      controller.dispose();
    });
  }

  @override
  void initState() {
    super.initState();

    // Crear el ViewModel aquí
    _viewModel = SeleccionPlatosViewModel();
    _viewModel.pedido = widget.initialDetalles;
    _viewModel.pedidoCodigoActual = widget.pedidoCodigo;
    _viewModel.loadData();

    // Configurar listeners de socket
    SocketService.onMesasActualizadasListener(() async {
      final mesas = await MesaService.obtenerMesas();
      final actual = mesas.firstWhere(
        (m) => m.codigo == widget.mesa.codigo,
        orElse: () => widget.mesa,
      );
      if (actual.estado == EstadoMesa.esperando && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    SocketService.onMenusActualizadosListener(() async {
      await _viewModel.loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SeleccionPlatosViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: _darkBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _darkSurface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mesa ${widget.mesa.numero}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.secondary.withValues(alpha:0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha:0.3),
                  ),
                ),
                child: Text(
                  widget.pedidoCodigo != null
                      ? 'Pedido ${widget.pedidoCodigo}'
                      : 'Nuevo Pedido',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _darkSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _viewModel.loadData(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Actualizar menú',
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header con información de la mesa
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha:0.1),
                    AppColors.secondary.withValues(alpha:0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha:0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForEstado(widget.mesa.estado),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mesa ${widget.mesa.numero}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(widget.mesa.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.mesa.estadoLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(widget.mesa.colorValue),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Barra de búsqueda usando el widget reutilizable 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Buscar platos...',
                onChanged: (value) {
                  _viewModel.updateSearch(value);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Lista de categorías (FILTRADAS por búsqueda)
            Expanded(
              child: Consumer<SeleccionPlatosViewModel>(
                builder: (context, vm, _) {
                  if (vm.loading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _darkSurface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Cargando menú...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (vm.categorias.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Filtrar categorías basándose en la búsqueda
                  final categoriasVisibles = _getCategoriasVisibles(vm);

                  return RefreshIndicator(
                    onRefresh: vm.loadData,
                    color: AppColors.primary,
                    backgroundColor: _darkSurface,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: categoriasVisibles
                          .map(
                            (cat) => MenuCategorySection(
                              categoria: cat,
                              fabKey: _fabKey,
                              runAddBubble: _runAddBubble,
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: PedidoFab(mesa: widget.mesa, fabKey: _fabKey),
      ),
    );
  }

  // Método para filtrar categorías basándose en la búsqueda
  List<dynamic> _getCategoriasVisibles(SeleccionPlatosViewModel vm) {
    // Si no hay texto de búsqueda, mostrar todas las categorías
    if (vm.searchText.isEmpty) {
      return vm.categorias;
    }
    
    // Si hay búsqueda, solo mostrar categorías que tengan productos coincidentes
    return vm.categorias.where((categoria) {
      // Obtener todos los menús de esta categoría
      final menusDeCategoria = vm.menus
          .where((menu) => menu.categoria?.codigo == categoria.codigo)
          .toList();
      
      // Verificar si algún menú coincide con la búsqueda
      final menusCoincidentes = menusDeCategoria.where((menu) {
        return menu.platos.toLowerCase().contains(vm.searchText.toLowerCase()) ||
               menu.descripcion.toLowerCase().contains(vm.searchText.toLowerCase());
      }).toList();
      
      return menusCoincidentes.isNotEmpty;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha:0.2),
                    AppColors.secondary.withValues(alpha:0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha:0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No hay categorías disponibles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Las categorías del menú aparecerán aquí cuando estén disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _viewModel.loadData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Actualizar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForEstado(EstadoMesa estado) {
    switch (estado) {
      case EstadoMesa.disponible:
        return Icons.table_restaurant_rounded;
      case EstadoMesa.ocupada:
        return Icons.people_rounded;
      case EstadoMesa.esperando:
        return Icons.access_time_rounded;
      case EstadoMesa.mantenimiento:
        return Icons.build_rounded;
    }
  }
}
