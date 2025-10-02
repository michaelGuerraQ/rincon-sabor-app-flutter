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
  _SelectInsumosScreenState createState() => _SelectInsumosScreenState();
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
    setState(() {
      allInsumos = list;
      filtered = list;
    });
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
      builder: (_) => NewInsumoDialog(),
    );
    if (created == true) {
      await _loadInsumos();
    }
  }

  Future<void> _toggleInsumo(Insumos insumo) async {
    final idx = seleccionados.indexWhere(
      (d) => d.insumoCodigo == insumo.codigo,
    );
    if (idx >= 0) {
      setState(() => seleccionados.removeAt(idx));
    } else {
      final qtyStr = await showDialog<String>(
        context: context,
        builder: (_) => _QuantityDialog(unidad: insumo.unidadMedida!),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark 
              ? Colors.white.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
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
                    onChanged: _filter,
                    hintText: 'Buscar insumos...',
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Nuevo insumo',
                    onPressed: _addNewInsumo,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de insumos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final ins = filtered[i];
                final sel = seleccionados.any((d) => d.insumoCodigo == ins.codigo);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D3748) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel 
                        ? AppColors.primary
                        : (isDark ? Colors.white.withOpacity(0.1) : AppColors.divider),
                      width: sel ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: sel 
                          ? AppColors.primary.withOpacity(0.2)
                          : (isDark 
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1)),
                        blurRadius: sel ? 12 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _toggleInsumo(ins),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: sel 
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_rounded,
                                color: sel ? AppColors.primary : AppColors.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ins.nombre!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unidad: ${ins.unidadMedida!}',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: sel 
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                sel ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: sel ? AppColors.primary : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
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
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () => Navigator.pop(context, seleccionados),
                icon: Icon(Icons.check_rounded, color: Colors.white),
                label: Text(
                  'Confirmar (${seleccionados.length})',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
  __QuantityDialogState createState() => __QuantityDialogState();
}

class __QuantityDialogState extends State<_QuantityDialog> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2D3748) : AppColors.surface,
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
            child: Icon(
              Icons.scale_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cantidad (${widget.unidad})',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Ingresa la cantidad',
          hintStyle: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: isDark 
            ? Colors.white.withOpacity(0.05)
            : AppColors.background,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
