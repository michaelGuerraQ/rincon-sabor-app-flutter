import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/view_model/insumos_view_mode.dart';
import 'package:rincon_sabor_flutter/core/widgets/insumo_listview.dart';
import 'package:rincon_sabor_flutter/core/widgets/input_search.dart';

class Insumoslistscreen extends StatefulWidget {
  const Insumoslistscreen({super.key});

  @override
  State<Insumoslistscreen> createState() => _InsumoslistscreenState();
}
/// Pantalla que muestra la lista de insumos
class _InsumoslistscreenState extends State<Insumoslistscreen> {
  @override
  void initState() {
    super.initState();
    // disparar la carga una vez que esté montado el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsumosViewModel>().cargarInsumos();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Obtiene el ViewModel de insumos desde el contexto
    /// Utiliza el Watch para reconstruir cuando cambie el estado
    /// y el tema actual para determinar si es oscuro o claro
    final vm = context.watch<InsumosViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
              boxShadow: [
                BoxShadow(
                  /// Color del sombreado
                  /// Utiliza un color más oscuro en modo oscuro
                  /// o un gris claro en modo claro
                  color:
                      isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            /// Encabezado con el título y la barra de búsqueda
            /// El título es "Insumos" y la barra de búsqueda permite filtrar insumos
            child: CustomSearchBar(
              controller: vm.searchController,
              hintText: 'Buscar insumo…',
              onChanged: vm.actualizarBusqueda,
            ),
          ),
          Expanded(
            child:
                vm.isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? const Color(0xFF2D3748)
                                      : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Colors.black.withValues(alpha: 0.3)
                                          : Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Cargando insumos...',
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: vm.cargarInsumos,
                      color: AppColors.primary,
                      backgroundColor:
                          isDark ? const Color(0xFF2D3748) : AppColors.surface,
                      child: InsumoListview(
                        insumos: vm.insumosFiltrados,
                        onActualizar:
                            (ins) => _showAbastecerInsumoDialog(
                              ins,
                            ).then((ok) => ok ?? false),
                        onEliminar: vm.eliminarInsumo,
                        onEditar:
                            (ins) async =>
                                (await _showEditarInsumoDialog(ins)) ?? false,
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            final created = await _showAgregarInsumoDialog();
            debugPrint('>> Diálogo devolvió created=$created');
            if (created == true) {
              await vm.cargarInsumos();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Insumo agregado correctamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (created == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No se creó el insumo'),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Future<bool?> _showAgregarInsumoDialog() async {
    final vm = context.read<InsumosViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nombreCtrl = TextEditingController();
    final unidadCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final costoTotalCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_rounded, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Text(
              'Nuevo Insumo',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nombreCtrl, 'Nombre', isDark),
              const SizedBox(height: 16),
              _buildTextField(unidadCtrl, 'Unidad de medida (Kg, unidad, etc)', isDark),
              const SizedBox(height: 16),
              _buildTextField(stockCtrl, 'Cantidad comprada', isDark, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(costoTotalCtrl, 'Costo total de compra', isDark, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final unidad = unidadCtrl.text.trim();
              final cantidad = double.tryParse(stockCtrl.text) ?? 0;
              final costoTotal = double.tryParse(costoTotalCtrl.text) ?? 0;

              // Llamamos al ViewModel en lugar del servicio directo
              final ok = await vm.agregarInsumo(
                nombre: nombre,
                unidad: unidad,
                stock: cantidad,
                costoTotal: costoTotal,
              );

              // CORRECCIÓN: Verificar si el contexto del diálogo sigue montado
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, ok);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    // CORRECCIÓN: Verificar mounted del widget principal
    if (!mounted) return null;

    return result;
  }

  Future<bool?> _showAbastecerInsumoDialog(Insumos ins) {
    final vm = context.read<InsumosViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cantidadCtrl = TextEditingController();
    final costoTotalCtrl = TextEditingController();

    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor:
                isDark ? const Color(0xFF2D3748) : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Abastecer ${ins.nombre}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  cantidadCtrl,
                  'Cantidad a ingresar',
                  isDark,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  costoTotalCtrl,
                  'Costo total de esta compra',
                  isDark,
                  isNumber: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nuevaCantidad = double.tryParse(cantidadCtrl.text) ?? 0;
                  final nuevoCostoTotal =
                      double.tryParse(costoTotalCtrl.text) ?? 0;

                  // en lugar de InsumosService.actualizarInsumo
                  final ok = await vm.actualizarInsumo(
                    ins,
                    nuevaCantidad: nuevaCantidad,
                    nuevoCostoTotal: nuevoCostoTotal,
                  );

                  if (!mounted) return;
                  Navigator.pop(ctx, ok);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Abastecer'),
              ),
            ],
          ),
    );
  }

  Future<bool?> _showEditarInsumoDialog(Insumos ins) {
    final vm = context.read<InsumosViewModel>(); // ← VM
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nombreCtrl = TextEditingController(text: ins.nombre);
    final unidadCtrl = TextEditingController(text: ins.unidadMedida);
    final stockCtrl = TextEditingController(text: ins.stockActual?.toString());
    final precioCtrl = TextEditingController(
      text: ins.compraUnidad?.toString(),
    );

    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor:
                isDark ? const Color(0xFF2D3748) : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Editar Insumo',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nombreCtrl, 'Nombre', isDark),
                  const SizedBox(height: 16),
                  _buildTextField(unidadCtrl, 'Unidad de medida', isDark),
                  const SizedBox(height: 16),
                  _buildTextField(
                    stockCtrl,
                    'Stock actual',
                    isDark,
                    isNumber: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    precioCtrl,
                    'Precio unidad',
                    isDark,
                    isNumber: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final nombre = nombreCtrl.text.trim();
                  final unidad = unidadCtrl.text.trim();
                  final stock = double.tryParse(stockCtrl.text) ?? 0;
                  final precio = double.tryParse(precioCtrl.text) ?? 0;
                  // ← Llamada al ViewModel
                  final ok = await vm.editarInsumo(
                    codigo: ins.codigo!,
                    nombre: nombre,
                    unidad: unidad,
                    stock: stock,
                    precio: precio,
                  );
                  if (!mounted) return;
                  Navigator.pop(ctx, ok);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isDark, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white30 : AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.background,
      ),
    );
  }
}
