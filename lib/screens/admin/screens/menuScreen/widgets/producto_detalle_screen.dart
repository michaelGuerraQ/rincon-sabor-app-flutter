import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/RecetaDetalle.dart';
import 'package:rincon_sabor_flutter/core/services/menu_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/widgets/editar_producto_screen.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final String menuCodigo;
  final String nombreProducto;

  const ProductoDetalleScreen({
    super.key,
    required this.menuCodigo,
    required this.nombreProducto,
  });

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  MenuDetallado? _menuDetallado;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalleProducto();
  }

  Future<void> _cargarDetalleProducto() async {
    setState(() => _isLoading = true);
    
    try {
      final detalle = await MenuService.obtenerMenuPorCodigo(widget.menuCodigo);
      setState(() {
        _menuDetallado = detalle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el producto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.nombreProducto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_menuDetallado != null)
            IconButton(
              onPressed: () => _navegarAEditar(),
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Editar producto',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando detalles...',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : _menuDetallado == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudo cargar el producto',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDetalleProducto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildDetalleContent(),
    );
  }

  Widget _buildDetalleContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menu = _menuDetallado!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          if (menu.menuImageUrl != null && menu.menuImageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  menu.menuImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

          // Información básica
          _buildInfoCard(
            'Información General',
            [
              _buildInfoRow('Nombre:', menu.menuPlatos),
              _buildInfoRow('Descripción:', menu.menuDescripcion),
              _buildInfoRow('Precio:', 'S/. ${menu.menuPrecio.toStringAsFixed(2)}'),
              _buildInfoRow('Estado:', menu.menuEstado == 'A' ? 'Activo' : 'Inactivo'),
              _buildInfoRow('Tipo:', menu.menuEsPreparado == 'A' ? 'Preparado' : 'Insumo Directo'),
            ],
          ),

          const SizedBox(height: 16),

          // Información específica según el tipo
          if (menu.menuEsPreparado == 'I') ...[
            // Producto de insumo directo
            _buildInfoCard(
              'Insumo Directo',
              [
                _buildInfoRow('Código Insumo:', menu.insumoDirectoCodigo ?? 'N/A'),
                _buildInfoRow('Nombre Insumo:', menu.insumoDirectoNombre ?? 'N/A'),
              ],
            ),
          ] else if (menu.menuEsPreparado == 'A' && menu.detallesReceta.isNotEmpty) ...[
            // Producto preparado con receta
            _buildRecetaCard(),
          ],

          const SizedBox(height: 20),

          // Botón de editar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navegarAEditar,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Editar Producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecetaCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receta (${_menuDetallado!.detallesReceta.length} ingredientes)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _menuDetallado!.detallesReceta.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final detalle = _menuDetallado!.detallesReceta[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    detalle.insumoNombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Stock: ${detalle.insumoStockActual} ${detalle.insumoUnidadMedida}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${detalle.recetaDetalleCantidadporPlato} ${detalle.insumoUnidadMedida}',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navegarAEditar() async {
    if (_menuDetallado == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProductoScreen(menuDetallado: _menuDetallado!),
      ),
    );

    // Si se editó exitosamente, recargar los detalles
    if (result == true) {
      _cargarDetalleProducto();
    }
  }
}
