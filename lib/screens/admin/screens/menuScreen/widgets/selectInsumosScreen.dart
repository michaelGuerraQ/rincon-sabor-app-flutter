import 'package:flutter/material.dart';
import 'package:rincon_sabor_flutter/core/models/DTO_MenuRequest.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';
import 'package:rincon_sabor_flutter/core/services/insumos_service.dart';
import 'package:rincon_sabor_flutter/core/theme/app_colors.dart';
import 'package:rincon_sabor_flutter/core/widgets/input_search.dart';
import 'package:rincon_sabor_flutter/screens/admin/screens/menuScreen/widgets/new_insumo_dialog.dart';

class SelectInsumosScreen extends StatefulWidget {
  final List<Insumos> insumos;
  final List<RecetaDetalleRequest> detallesExistentes;

  const SelectInsumosScreen({
    super.key,
    required this.insumos,
    required this.detallesExistentes,
  });

  @override
  State<SelectInsumosScreen> createState() => _SelectInsumosScreenState();
}

class _SelectInsumosScreenState extends State<SelectInsumosScreen> {
  late List<Insumos> allInsumos;
  late List<Insumos> filtered;
  late List<RecetaDetalleRequest> seleccionados;

  @override
  void initState() {
    super.initState();
    allInsumos = widget.insumos;
    filtered = allInsumos;
    seleccionados = List.from(widget.detallesExistentes);
    _loadInsumos();
  }

  Future<void> _loadInsumos() async {
    final list = await InsumosService.listarInsumos();
    if (mounted) {
      setState(() {
        allInsumos = list;
        filtered = list;
      });
    }
  }

  void _filter(String q) {
    setState(() {
      filtered = allInsumos
          .where((i) => i.nombre!.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addNewInsumo() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const NewInsumoDialog(),
    );
    if (created == true) await _loadInsumos();
  }

  Future<void> _toggleInsumo(Insumos insumo) async {
    final idx = seleccionados.indexWhere((d) => d.insumoCodigo == insumo.codigo);
    if (idx >= 0) {
      setState(() => seleccionados.removeAt(idx));
    } else {
      final qtyStr = await showDialog<String>(
        context: context,
        builder: (_) => _QuantityDialog(unidad: insumo.unidadMedida ?? '-'),
      );
      final qty = double.tryParse(qtyStr ?? '');
      if (qty != null) {
        setState(() {
          seleccionados.add(
            RecetaDetalleRequest(
              insumoCodigo: insumo.codigo!,
              cantidadPorPlato: qty,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: const Key('select_insumos_screen'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        key: const Key('select_insumos_appbar'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        leading: IconButton(
          key: const Key('btn_back_insumos'),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seleccionar Insumos',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Header con búsqueda y botón agregar
          Container(
            key: const Key('header_busqueda_insumos'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    key: const Key('search_insumo_field'),
                    onChanged: _filter,
                    hintText: 'Buscar insumos...',
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  key: const Key('btn_add_insumo'),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  tooltip: 'Nuevo insumo',
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(AppColors.secondary),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  onPressed: _addNewInsumo,
                ),
              ],
            ),
          ),

          // Lista de insumos
          Expanded(
            child: ListView.builder(
              key: const Key('list_insumos'),
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final ins = filtered[i];
                final sel = seleccionados
                    .any((d) => d.insumoCodigo == ins.codigo);

                return Container(
                  key: Key('insumo_item_${ins.codigo}'),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary
                          : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.divider),
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _toggleInsumo(ins),
                    leading: Icon(
                      sel
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color:
                      sel ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      ins.nombre ?? 'Sin nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                        isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Unidad: ${ins.unidadMedida ?? '-'}',
                      style: TextStyle(
                        color:
                        isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Botón flotante de confirmar
      floatingActionButton: seleccionados.isNotEmpty
          ? FloatingActionButton.extended(
        key: const Key('btn_confirmar_insumos'),
        backgroundColor: AppColors.success,
        onPressed: () => Navigator.pop(context, seleccionados),
        icon: const Icon(Icons.check_rounded, color: Colors.white),
        label: Text(
          'Confirmar (${seleccionados.length})',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }
}

class _QuantityDialog extends StatefulWidget {
  final String unidad;
  const _QuantityDialog({required this.unidad});

  @override
  State<_QuantityDialog> createState() => __QuantityDialogState();
}

class __QuantityDialogState extends State<_QuantityDialog> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      key: const Key('dialog_cantidad_insumo'),
      backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Cantidad (${widget.unidad})',
          style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold)),
      content: TextField(
        key: const Key('field_cantidad_insumo'),
        controller: _ctrl,
        keyboardType: TextInputType.number,
        autofocus: true,
        style:
        TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Ingresa la cantidad',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('btn_cancelar_cantidad'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          key: const Key('btn_confirmar_cantidad'),
          onPressed: () => Navigator.pop(context, _ctrl.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
