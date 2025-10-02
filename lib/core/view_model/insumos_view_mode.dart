import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';
import 'package:rincon_sabor_flutter/core/services/insumos_service.dart';

class InsumosViewModel with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  
  List<Insumos> _insumos = [];
  bool _isLoading = true;
  String _searchText = '';

  List<Insumos> get insumos => _insumos;
  bool get isLoading => _isLoading;

  List<Insumos> get insumosFiltrados {
    return _insumos.where((ins) {
      final nombre = ins.nombre?.toLowerCase() ?? '';
      return nombre.contains(_searchText.toLowerCase());
    }).toList();
  }
  /// Inicializa el ViewModel y carga los insumos
  void actualizarBusqueda(String texto) {
    _searchText = texto;
    notifyListeners();
  }
  /// Carga los insumos desde el servicio
  /// Llama a [cargarInsumos] para obtener la lista actualizada
  /// @param texto Texto de búsqueda para filtrar insumos
  Future<void> cargarInsumos() async {
    _isLoading = true;
    notifyListeners();
    _insumos = await InsumosService.listarInsumos();
    _isLoading = false;
    notifyListeners();
  }
  
  /// Agrega un nuevo insumo
  Future<bool> agregarInsumo({
    required String nombre,
    required String unidad,
    required double stock,
    required double costoTotal,
  }) async {
    final double precioUnidad = stock > 0 ? costoTotal / stock : 0;

    final ok = await InsumosService.crearInsumo(
      nombre: nombre,
      unidadMedida: unidad,
      stockActual: stock,
      compraUnidad: precioUnidad,
    );
    if (ok) await cargarInsumos();
    return ok;
  }
  /// Abastece un insumo existente
  /// Actualiza el stock y el costo total del insumo
  Future<bool> actualizarInsumo(Insumos insumo, {
    required double nuevaCantidad,
    required double nuevoCostoTotal,
  }) async {
    final stockViejo = insumo.stockActual ?? 0;
    final precioViejo = insumo.compraUnidad ?? 0;
    final costoViejoTotal = stockViejo * precioViejo;
    /// Calcula el nuevo costo total 
    /// esta es sacar el promedio ponderado
    final stockTotal = stockViejo + nuevaCantidad;
    final double precioPromedio = stockTotal > 0
        ? (costoViejoTotal + nuevoCostoTotal) / stockTotal
        : 0;

    final ok = await InsumosService.actualizarInsumo(
      codigo: insumo.codigo!,
      nombre: insumo.nombre!,
      unidadMedida: insumo.unidadMedida!,
      stockActual: stockTotal,
      compraUnidad: precioPromedio,
    );
    if (ok) await cargarInsumos();
    return ok;
  }
  /// Edita un insumo existente
  /// Permite cambiar el nombre, unidad, stock y precio de un insumo
  Future<bool> editarInsumo({
    required String codigo,
    required String nombre,
    required String unidad,
    required double stock,
    required double precio,
  }) async {
    final ok = await InsumosService.actualizarInsumo(
      codigo: codigo,
      nombre: nombre,
      unidadMedida: unidad,
      stockActual: stock,
      compraUnidad: precio,
    );
    if (ok) await cargarInsumos();
    return ok;
  }

  Future<bool> eliminarInsumo(Insumos insumo) async {
    // Por ahora no implementado
    return false;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
