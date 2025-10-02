import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/models/DTO_MenuRequest.dart';
import 'package:rincon_sabor_flutter/core/models/menu.dart';
import 'package:rincon_sabor_flutter/core/services/categoria_service.dart';
import 'package:rincon_sabor_flutter/core/services/menu_service.dart';
import 'package:rincon_sabor_flutter/core/services/socket_service.dart';

class ProductosListViewModel extends ChangeNotifier {
  // Estados privados
  List<Menu> _productos = [];
  List<Categoria> _categorias = [];
  final Map<String, bool> _categoriasVisibles = {};
  bool _isLoading = true;
  String _searchText = '';

  // Getters públicos
  List<Menu> get productos => _productos;
  List<Categoria> get categorias => _categorias;
  Map<String, bool> get categoriasVisibles => _categoriasVisibles;
  bool get isLoading => _isLoading;
  String get searchText => _searchText;

  // Constructor
  ProductosListViewModel() {
    _inicializar();
  }

  // Inicialización
  void _inicializar() {
    cargarDatosIniciales();
    SocketService.onMenusActualizadosListener(cargarDatosIniciales);
  }

  // Cargar datos iniciales
  Future<void> cargarDatosIniciales() async {
    _setLoading(true);
    
    try {
      final productos = await MenuService.obtenerMenus();
      final categorias = await CategoriaService.obtenerCategorias();
      
      _productos = productos;
      _categorias = categorias;
      
      // Inicializar visibilidad de categorías
      _categoriasVisibles.clear();
      for (var categoria in _categorias) {
        _categoriasVisibles[categoria.nombre] = true;
      }
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error al cargar datos: $e');
    }
  }

  // Cambiar estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Toggle visibilidad de categoría
  void toggleCategoriaVisibility(String categoriaNombre) {
    _categoriasVisibles[categoriaNombre] = !(_categoriasVisibles[categoriaNombre] ?? false);
    notifyListeners();
  }

  // Actualizar texto de búsqueda
  void updateSearchText(String searchText) {
    _searchText = searchText;
    notifyListeners();
  }

  // Obtener categorías visibles según búsqueda
  List<Categoria> getCategoriasVisibles() {
    if (_searchText.isEmpty) {
      return _categorias;
    }
    
    return _categorias.where((categoria) {
      final productosDeCategoria = _productos
          .where((p) => p.categoria!.codigo == categoria.codigo)
          .toList();
      
      final productosCoincidentes = productosDeCategoria.where((p) {
        return p.platos.toLowerCase().contains(_searchText.toLowerCase());
      }).toList();
      
      return productosCoincidentes.isNotEmpty;
    }).toList();
  }

  // Obtener productos filtrados por categoría y búsqueda
  List<Menu> getProductosFiltrados(Categoria categoria) {
    final listForCat = _productos
        .where((p) => p.categoria!.codigo == categoria.codigo)
        .toList();
    
    return listForCat.where((p) {
      return p.platos.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  // Eliminar producto
  Future<bool> eliminarProducto(String codigoProducto) async {
    try {
      final eliminado = await MenuService.eliminarMenu(codigoProducto);
      
      if (eliminado) {
        _productos.removeWhere((p) => p.codigo == codigoProducto);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al eliminar producto: $e');
      return false;
    }
  }

  // Método para actualizar producto
  Future<bool> actualizarProducto(MenuUpdateRequest menuUpdateRequest) async {
    try {
      final actualizado = await MenuService.actualizarMenu(menuUpdateRequest);
      
      if (actualizado) {
        // Recargar los datos para reflejar los cambios
        await cargarDatosIniciales();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al actualizar producto: $e');
      return false;
    }
  }

  // Refrescar datos (para pull-to-refresh)
  Future<void> refresh() async {
    await cargarDatosIniciales();
  }

  @override
  void dispose() {
    // Limpiar listeners si es necesario
    super.dispose();
  }
}
