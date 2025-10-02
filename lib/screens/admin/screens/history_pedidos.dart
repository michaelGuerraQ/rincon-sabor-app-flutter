import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rincon_sabor_flutter/core/models/Pedido.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import '../components/pedido_history.dart';

class HistoryPedidosScreen extends StatefulWidget {
  const HistoryPedidosScreen({super.key});

  @override
  State<HistoryPedidosScreen> createState() => _HistoryPedidosScreenState();
}

class _HistoryPedidosScreenState extends State<HistoryPedidosScreen> {
  late Future<List<PedidoHistory>> _historialFuture;
  int _page = 1;
  final int _limit = 10;
  List<PedidoHistory> _pedidos = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _apiFilterWarning = false;

  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  // Debug flag to simulate local filtering if API doesn't filter
  static const bool _simulateLocalFiltering = true;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  // Función para cargar los pedidos desde la API, con opción de resetear paginación
  void _loadPedidos({bool reset = false}) {
    if (_fechaDesde != null && _fechaHasta != null && _fechaHasta!.isBefore(_fechaDesde!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin no puede ser anterior a la fecha de inicio')),
      );
      return;
    }

    if (reset) {
      setState(() {
        _page = 1;
        _pedidos = [];
        _hasMore = true;
        _isLoadingMore = true;
        _apiFilterWarning = false;
      });
    }

    // Normalize dates to midnight for fechaDesde and end-of-day for fechaHasta
    final fechaDesde = _fechaDesde != null
        ? DateTime(_fechaDesde!.year, _fechaDesde!.month, _fechaDesde!.day)
        : null;
    final fechaHasta = _fechaHasta != null
        ? DateTime(_fechaHasta!.year, _fechaHasta!.month, _fechaHasta!.day, 23, 59, 59)
        : null;

    // Log dates for debugging
    final fechaDesdeStr = fechaDesde != null ? DateFormat('yyyy-MM-dd').format(fechaDesde) : 'null';
    final fechaHastaStr = fechaHasta != null ? DateFormat('yyyy-MM-dd').format(fechaHasta) : 'null';
    print('Loading pedidos: page=$_page, fechaDesde=$fechaDesdeStr, fechaHasta=$fechaHastaStr');

    _historialFuture = PedidoHistory.loadHistorial(
      page: _page,
      limit: _limit,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    ).then((pedidos) {
      // Check if API returned unfiltered data
      bool isUnfiltered = false;
      if (fechaDesde != null || fechaHasta != null) {
        isUnfiltered = pedidos.any((pedido) {
          if (fechaDesde != null && pedido.fecha.isBefore(fechaDesde)) return true;
          if (fechaHasta != null && pedido.fecha.isAfter(fechaHasta)) return true;
          return false;
        });
      }

      // Simulate local filtering if API doesn't filter
      List<PedidoHistory> filteredPedidos = pedidos;
      if (_simulateLocalFiltering && (fechaDesde != null || fechaHasta != null)) {
        filteredPedidos = pedidos.where((pedido) {
          if (fechaDesde != null && pedido.fecha.isBefore(fechaDesde)) return false;
          if (fechaHasta != null && pedido.fecha.isAfter(fechaHasta)) return false;
          return true;
        }).toList();
        print('After local filtering: ${filteredPedidos.length} pedidos');
      }

      setState(() {
        if (_page == 1) {
          _pedidos = filteredPedidos;
        } else {
          _pedidos.addAll(filteredPedidos);
        }
        _hasMore = filteredPedidos.length == _limit;
        _isLoadingMore = false;
        _apiFilterWarning = isUnfiltered && !_simulateLocalFiltering;
      });
      return _pedidos;
    }).catchError((error) {
      setState(() {
        _isLoadingMore = false;
      });
      print('Error loading pedidos: $error');
      throw error;
    });
  }

  // Función para cargar más pedidos cuando el usuario hace scroll
  void _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _page++;
    _loadPedidos();
  }

  // Función para actualizar la pantalla (onRefresh)
  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _pedidos = [];
      _hasMore = true;
    });
    _loadPedidos();
  }

  // Método para seleccionar la fecha de inicio
  Future<void> _selectFechaDesde(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _fechaDesde ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != _fechaDesde) {
      setState(() {
        _fechaDesde = selectedDate;
      });
      print('Fecha Desde selected: $_fechaDesde');
      _loadPedidos(reset: true);
    }
  }

  // Método para seleccionar la fecha de fin
  Future<void> _selectFechaHasta(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != _fechaHasta) {
      setState(() {
        _fechaHasta = selectedDate;
      });
      print('Fecha Hasta selected: $_fechaHasta');
      _loadPedidos(reset: true);
    }
  }

  // Método para limpiar el filtro de fecha
  void _clearFilter() {
    setState(() {
      _fechaDesde = null;
      _fechaHasta = null;
    });
    print('Filters cleared');
    _loadPedidos(reset: true);
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Color(EstadoPedido.pendiente.colorValue);
      case 'Listo':
        return Color(EstadoPedido.listo.colorValue);
      case 'Servido':
        return Color(EstadoPedido.servido.colorValue);
      case 'Cancelado':
        return Color(EstadoPedido.cancelado.colorValue);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Filtrar por Fecha'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            _fechaDesde == null
                                ? 'Fecha Desde: No seleccionada'
                                : 'Fecha Desde: ${DateFormat('dd/MM/yyyy').format(_fechaDesde!)}',
                          ),
                          onTap: () async {
                            await _selectFechaDesde(context);
                            if (_fechaDesde != null && _fechaHasta != null) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        ListTile(
                          title: Text(
                            _fechaHasta == null
                                ? 'Fecha Hasta: No seleccionada'
                                : 'Fecha Hasta: ${DateFormat('dd/MM/yyyy').format(_fechaHasta!)}',
                          ),
                          onTap: () async {
                            await _selectFechaHasta(context);
                            if (_fechaDesde != null && _fechaHasta != null) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearFilter();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Limpiar filtros'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_fechaDesde != null &&
                              _fechaHasta != null &&
                              _fechaHasta!.isBefore(_fechaDesde!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'La fecha de fin no puede ser anterior a la fecha de inicio')),
                            );
                            return;
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Aplicar filtros'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_fechaDesde != null || _fechaHasta != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Filtrado: ${_fechaDesde != null ? DateFormat('dd/MM/yyyy').format(_fechaDesde!) : 'Inicio'} - ${_fechaHasta != null ? DateFormat('dd/MM/yyyy').format(_fechaHasta!) : 'Fin'}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _clearFilter,
                  ),
                ],
              ),
            ),
          if (_apiFilterWarning)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Advertencia: El servidor no está filtrando por fechas correctamente. Contacte al soporte técnico.',
                style: TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<PedidoHistory>>(
                future: _historialFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _pedidos.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadPedidos(reset: true),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  } else if (_pedidos.isEmpty) {
                    return Center(
                      child: Text(
                        _fechaDesde != null || _fechaHasta != null
                            ? 'No se encontraron pedidos para el rango de fechas seleccionado'
                            : 'No hay historial disponible',
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                          _hasMore) {
                        _loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pedidos.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                      const Divider(height: 24),
                      itemBuilder: (context, index) {
                        if (index == _pedidos.length && _hasMore) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final pedido = _pedidos[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pedido #${pedido.numeroPedido}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Chip(
                                      backgroundColor: _getEstadoColor(
                                          pedido.estado)
                                          .withOpacity(0.2),
                                      label: Text(
                                        pedido.estado,
                                        style: TextStyle(
                                          color:
                                          _getEstadoColor(pedido.estado),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy - HH:mm')
                                      .format(pedido.fecha),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Mesa: ${pedido.mesa}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Items:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                ...pedido.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        '• ${item.nombre}',
                                        style: TextStyle(
                                            color: Colors.grey[700]),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${item.cantidad}x S/ ${item.precio.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'S/ ${pedido.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}