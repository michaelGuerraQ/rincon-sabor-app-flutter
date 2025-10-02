import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/RecetaDetalle.dart';
import 'package:rincon_sabor_flutter/core/models/DTO_MenuRequest.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';
import 'package:rincon_sabor_flutter/core/services/insumos_service.dart';
import 'package:rincon_sabor_flutter/core/services/menu_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';

class EditarProductoScreen extends StatefulWidget {
  final MenuDetallado menuDetallado;

  const EditarProductoScreen({
    super.key,
    required this.menuDetallado,
  });

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingInsumos = false;
  String _estadoSeleccionado = 'A';
  List<RecetaDetalleEditable> _detallesReceta = [];
  List<Insumos> _insumosDisponibles = [];

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
    _cargarInsumos();
  }

  void _inicializarFormulario() {
    _nombreController.text = widget.menuDetallado.menuPlatos;
    _descripcionController.text = widget.menuDetallado.menuDescripcion;
    _precioController.text = widget.menuDetallado.menuPrecio.toString();
    _estadoSeleccionado = widget.menuDetallado.menuEstado;

    if (widget.menuDetallado.menuEsPreparado == 'A') {
      _detallesReceta = widget.menuDetallado.detallesReceta.map((detalle) =>
          RecetaDetalleEditable(
            insumoCodigo: detalle.insumoCodigo,
            insumoNombre: detalle.insumoNombre,
            cantidad: detalle.recetaDetalleCantidadporPlato,
            unidadMedida: detalle.insumoUnidadMedida,
            stockActual: detalle.insumoStockActual,
          )
      ).toList();
    }
  }

  Future<void> _cargarInsumos() async {
    if (!mounted) return;
    setState(() => _isLoadingInsumos = true);

    try {
      final insumos = await InsumosService.listarInsumos();
      if (!mounted) return;
      setState(() {
        _insumosDisponibles = insumos;
        _isLoadingInsumos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingInsumos = false);
      debugPrint('Error al cargar insumos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar insumos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  // ==========================================================
  // INICIO DE LA CORRECCIÓN PRINCIPAL
  // ==========================================================
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.menuDetallado.menuEsPreparado == 'A' && _detallesReceta.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debe agregar al menos un ingrediente'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final menuUpdateRequest = MenuUpdateRequest(
        menuCodigo: widget.menuDetallado.menuCodigo,
        menuPlatos: _nombreController.text.trim(),
        menuDescripcion: _descripcionController.text.trim(),
        menuPrecio: double.parse(_precioController.text),
        menuEstado: _estadoSeleccionado,
        menuImageUrl: widget.menuDetallado.menuImageUrl,
        menuCategoriaCodigo: widget.menuDetallado.menuCategoriaCodigo,
        menuEsPreparado: widget.menuDetallado.menuEsPreparado,
        menuInsumoCodigo: widget.menuDetallado.insumoDirectoCodigo,
        detallesReceta: widget.menuDetallado.menuEsPreparado == 'A'
            ? _detallesReceta.map((detalle) =>
            RecetaDetalle(
              insumoCodigo: detalle.insumoCodigo,
              cantidad: detalle.cantidad,
            )).toList()
            : null,
      );

      final actualizado = await MenuService.actualizarMenu(menuUpdateRequest);

      // CORRECCIÓN: Si todo está bien, simplemente cerramos la pantalla
      // y devolvemos 'true' como resultado.
      if (!mounted) return;
      Navigator.pop(context, actualizado); // Devuelve true si fue exitoso, false si no

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, false); // En caso de error, devuelve false

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ==========================================================
  // FIN DE LA CORRECCIÓN PRINCIPAL
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Editar Producto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... El resto de tu UI (Cards de información y receta)
              // ... (Este código no necesita cambios, por eso se omite por brevedad)
              // ... Tu código de Cards aquí
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Información General',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del producto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.restaurant_menu, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.description, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precioController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Precio (S/.)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El precio es obligatorio';
                          }
                          final precio = double.tryParse(value);
                          if (precio == null || precio <= 0) {
                            return 'Ingrese un precio válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _estadoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.toggle_on, color: AppColors.primary),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('Activo')),
                          DropdownMenuItem(value: 'I', child: Text('Inactivo')),
                        ],
                        onChanged: (value) {
                          if (value != null && mounted) {
                            setState(() {
                              _estadoSeleccionado = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.menuDetallado.menuEsPreparado == 'A')
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text(
                              'Gestión de Receta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Editable',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Puedes agregar, modificar cantidades y eliminar ingredientes de la receta.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoadingInsumos ? null : _mostrarDialogoAgregarInsumo,
                            icon: _isLoadingInsumos
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Icon(Icons.add, size: 20),
                            label: Text(_isLoadingInsumos ? 'Cargando insumos...' : 'Agregar Ingrediente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_detallesReceta.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.warning_amber, color: AppColors.warning, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Sin ingredientes en la receta',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Agrega al menos un ingrediente para completar la receta',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingredientes (${_detallesReceta.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...(_detallesReceta.asMap().entries.map((entry) {
                                final index = entry.key;
                                final detalle = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(bottom: index < _detallesReceta.length - 1 ? 12 : 0),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A202C).withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.restaurant_menu,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              detalle.insumoNombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Stock disponible: ${detalle.stockActual} ${detalle.unidadMedida}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          initialValue: detalle.cantidad.toString(),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            labelText: detalle.unidadMedida,
                                            labelStyle: const TextStyle(fontSize: 12),
                                          ),
                                          onChanged: (value) {
                                            final cantidad = double.tryParse(value);
                                            if (cantidad != null && cantidad > 0 && mounted) {
                                              setState(() {
                                                _detallesReceta[index].cantidad = cantidad;
                                              });
                                            }
                                          },
                                          validator: (value) {
                                            final cantidad = double.tryParse(value ?? '');
                                            if (cantidad == null || cantidad <= 0) {
                                              return 'Inválida';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            if (!mounted) return;
                                            setState(() {
                                              _detallesReceta.removeAt(index);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${detalle.insumoNombre} eliminado de la receta'),
                                                backgroundColor: AppColors.info,
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                          tooltip: 'Eliminar ingrediente',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.textSecondary),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarCambios, // Llama al método corregido
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Guardar Cambios'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarInsumo() {
    if (_insumosDisponibles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No hay insumos disponibles para agregar'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Agregar Ingrediente'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona un insumo para agregar a la receta:',
                style: TextStyle(
                  color: Theme.of(dialogContext).brightness == Brightness.dark
                      ? Colors.white70
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _insumosDisponibles.length,
                  itemBuilder: (context, index) {
                    final insumo = _insumosDisponibles[index];
                    final yaAgregado = _detallesReceta.any((d) => d.insumoCodigo == insumo.codigo);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: yaAgregado
                                ? Colors.grey.withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            yaAgregado ? Icons.check : Icons.restaurant_menu,
                            color: yaAgregado ? Colors.grey : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          insumo.nombre!,
                          style: TextStyle(
                            color: yaAgregado ? Colors.grey : null,
                            fontWeight: yaAgregado ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Stock: ${insumo.stockActual} ${insumo.unidadMedida}',
                          style: TextStyle(
                            color: yaAgregado ? Colors.grey : null,
                          ),
                        ),
                        trailing: yaAgregado
                            ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Ya agregado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        )
                            : Icon(Icons.add_circle, color: AppColors.success),
                        onTap: yaAgregado ? null : () {
                          if (!mounted) return;
                          setState(() {
                            _detallesReceta.add(RecetaDetalleEditable(
                              insumoCodigo: insumo.codigo!,
                              insumoNombre: insumo.nombre!,
                              cantidad: 1.0,
                              unidadMedida: insumo.unidadMedida!,
                              stockActual: insumo.stockActual!,
                            ));
                          });
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${insumo.nombre} agregado a la receta'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}


// Clase auxiliar
class RecetaDetalleEditable {
  final String insumoCodigo;
  final String insumoNombre;
  double cantidad;
  final String unidadMedida;
  final double stockActual;

  RecetaDetalleEditable({
    required this.insumoCodigo,
    required this.insumoNombre,
    required this.cantidad,
    required this.unidadMedida,
    required this.stockActual,
  });
}
