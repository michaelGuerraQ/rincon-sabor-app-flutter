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

class _InsumoslistscreenState extends State<Insumoslistscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsumosViewModel>().cargarInsumos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InsumosViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: const Key('insumos_list_screen'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // 🔎 Barra de búsqueda
          Container(
            key: const Key('searchbar_insumos_container'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomSearchBar(
              key: const Key('searchbar_insumos'),
              controller: vm.searchController,
              hintText: 'Buscar insumo…',
              onChanged: vm.actualizarBusqueda,
            ),
          ),

          // 📦 Contenido principal (loading o lista)
          Expanded(
            child: vm.isLoading
                ? Center(
              key: const Key('insumos_loading_state'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    key: const Key('progress_insumos'),
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  const Text('Cargando insumos...'),
                ],
              ),
            )
                : RefreshIndicator(
              key: const Key('insumos_refresh'),
              onRefresh: vm.cargarInsumos,
              color: AppColors.primary,
              backgroundColor:
              isDark ? const Color(0xFF2D3748) : AppColors.surface,
              child: InsumoListview(
                key: const Key('insumos_listview'),
                insumos: vm.insumosFiltrados,
                onActualizar: (ins) =>
                    _showAbastecerInsumoDialog(ins).then((ok) => ok ?? false),
                onEliminar: vm.eliminarInsumo,
                onEditar: (ins) async =>
                (await _showEditarInsumoDialog(ins)) ?? false,
              ),
            ),
          ),
        ],
      ),

      // ➕ Botón flotante
      floatingActionButton: FloatingActionButton(
        key: const Key('btn_agregar_insumo'),
        backgroundColor: AppColors.secondary,
        onPressed: () async {
          final created = await _showAgregarInsumoDialog();
          if (created == true) {
            await vm.cargarInsumos();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                key: Key('snackbar_insumo_agregado'),
                content: Text('Insumo agregado correctamente'),
              ),
            );
          }
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // 🧩 Diálogo: Agregar nuevo insumo
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
        key: const Key('dialog_agregar_insumo'),
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        title: const Text('Nuevo Insumo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nombreCtrl, 'Nombre', isDark, key: const Key('field_nombre_insumo')),
            const SizedBox(height: 16),
            _buildTextField(unidadCtrl, 'Unidad de medida', isDark,
                key: const Key('field_unidad_insumo')),
            const SizedBox(height: 16),
            _buildTextField(stockCtrl, 'Cantidad', isDark,
                key: const Key('field_cantidad_insumo'), isNumber: true),
            const SizedBox(height: 16),
            _buildTextField(costoTotalCtrl, 'Costo total', isDark,
                key: const Key('field_costo_insumo'), isNumber: true),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancelar_insumo'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('btn_guardar_insumo'),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final unidad = unidadCtrl.text.trim();
              final cantidad = double.tryParse(stockCtrl.text) ?? 0;
              final costoTotal = double.tryParse(costoTotalCtrl.text) ?? 0;

              final ok = await vm.agregarInsumo(
                nombre: nombre,
                unidad: unidad,
                stock: cantidad,
                costoTotal: costoTotal,
              );

              if (dialogContext.mounted) Navigator.pop(dialogContext, ok);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted) return null;
    return result;
  }

  // 🧩 Diálogo reutilizable para abastecer y editar
  Future<bool?> _showAbastecerInsumoDialog(Insumos ins) {
    final vm = context.read<InsumosViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cantidadCtrl = TextEditingController();
    final costoTotalCtrl = TextEditingController();

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('dialog_abastecer_insumo'),
        title: Text('Abastecer ${ins.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(cantidadCtrl, 'Cantidad', isDark,
                key: const Key('field_abastecer_cantidad')),
            const SizedBox(height: 16),
            _buildTextField(costoTotalCtrl, 'Costo total', isDark,
                key: const Key('field_abastecer_costo')),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancelar_abastecer'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('btn_confirmar_abastecer'),
            onPressed: () async {
              final cantidad = double.tryParse(cantidadCtrl.text) ?? 0;
              final costo = double.tryParse(costoTotalCtrl.text) ?? 0;
              final ok = await vm.actualizarInsumo(ins,
                  nuevaCantidad: cantidad, nuevoCostoTotal: costo);
              if (ctx.mounted) Navigator.pop(ctx, ok);
            },
            child: const Text('Abastecer'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showEditarInsumoDialog(Insumos ins) {
    final vm = context.read<InsumosViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nombreCtrl = TextEditingController(text: ins.nombre);
    final unidadCtrl = TextEditingController(text: ins.unidadMedida);
    final stockCtrl = TextEditingController(text: ins.stockActual?.toString());
    final precioCtrl = TextEditingController(text: ins.compraUnidad?.toString());

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('dialog_editar_insumo'),
        title: const Text('Editar Insumo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nombreCtrl, 'Nombre', isDark,
                key: const Key('edit_field_nombre_insumo')),
            const SizedBox(height: 16),
            _buildTextField(unidadCtrl, 'Unidad', isDark,
                key: const Key('edit_field_unidad_insumo')),
            const SizedBox(height: 16),
            _buildTextField(stockCtrl, 'Stock', isDark,
                key: const Key('edit_field_stock_insumo'), isNumber: true),
            const SizedBox(height: 16),
            _buildTextField(precioCtrl, 'Precio', isDark,
                key: const Key('edit_field_precio_insumo'), isNumber: true),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancelar_editar'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('btn_guardar_editar'),
            onPressed: () async {
              final ok = await vm.editarInsumo(
                codigo: ins.codigo!,
                nombre: nombreCtrl.text.trim(),
                unidad: unidadCtrl.text.trim(),
                stock: double.tryParse(stockCtrl.text) ?? 0,
                precio: double.tryParse(precioCtrl.text) ?? 0,
              );
              if (ctx.mounted) Navigator.pop(ctx, ok);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Campo de texto genérico (reutilizado)
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      bool isDark, {
        bool isNumber = false,
        Key? key,
      }) {
    return TextField(
      key: key,
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
