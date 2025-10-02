import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rincon_sabor_flutter/core/models/Categoria_producto.dart';
import 'package:rincon_sabor_flutter/core/models/DTO_MenuRequest.dart';
import 'package:rincon_sabor_flutter/core/models/insumos.dart';
import 'package:rincon_sabor_flutter/core/services/categoria_service.dart';
import 'package:rincon_sabor_flutter/core/services/insumos_service.dart';
import 'package:rincon_sabor_flutter/core/services/menu_service.dart';

class AgregarMenuModel extends ChangeNotifier {
  // controllers
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final compraCtrl = TextEditingController();

  bool esPreparado = false;
  bool isSaving = false;

  List<Insumos> insumos = [];
  List<Categoria> categorias = [];
  String? selectedCategoria;
  String? toAddCodigo;
  List<RecetaDetalleRequest> detalles = [];
  XFile? pickedImage;
  Uint8List? imageData;

  AgregarMenuModel() {
    loadInsumos();
    loadCategorias();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    unitCtrl.dispose();
    stockCtrl.dispose();
    compraCtrl.dispose();

    super.dispose();
  }

  void _safeNotify() {
    if (hasListeners) notifyListeners();
  }

  Future<void> loadInsumos() async {
    final list = await InsumosService.listarInsumos();
    insumos = list;
    _safeNotify();
  }

  Future<void> loadCategorias() async {
    final cats = await CategoriaService.obtenerCategorias();
    categorias = cats;
    if (cats.isNotEmpty) selectedCategoria = cats.first.codigo;
    _safeNotify();
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    pickedImage = img;
    // leer bytes siempre (web o mobile)
    imageData = await img.readAsBytes();
    notifyListeners();
  }

  void togglePreparado(bool v) {
    esPreparado = v;
    detalles.clear();
    notifyListeners();
  }

  void setDetalles(List<RecetaDetalleRequest> nuevos) {
    detalles = nuevos;
    notifyListeners();
  }

  void addDetalle() {
    if (toAddCodigo == null) return;
    if (!detalles.any((d) => d.insumoCodigo == toAddCodigo)) {
      detalles.add(
        RecetaDetalleRequest(insumoCodigo: toAddCodigo!, cantidadPorPlato: 0),
      );
      toAddCodigo = null;
      notifyListeners();
    }
  }

  void removeDetalle(String c) {
    detalles.removeWhere((d) => d.insumoCodigo == c);
    notifyListeners();
  }

  void updateDetalle(String codigo, double cantidad) {
    final i = detalles.indexWhere((d) => d.insumoCodigo == codigo);
    detalles[i] = RecetaDetalleRequest(
      insumoCodigo: codigo,
      cantidadPorPlato: cantidad,
    );
    notifyListeners();
  }

  void clearImage() {
    pickedImage = null;
    imageData = null;
    notifyListeners();
  }

  /// este submit es para agregar un nuevo plato al menú
  /// si es un plato preparado, se envía la receta
  /// si es un insumo, se envía el insumo
  /// si es un plato preparado, se envía la imagen del plato
  /// si es un insumo, no se envía la imagen
  /// si es un plato preparado, se envía la categoría del plato
  /// si es un insumo, no se envía la categoría
  /// si es un plato preparado, se envía el nombre del plato
  /// si es un insumo, se envía el nombre del insumo
  /// si es un plato preparado, se envía la descripción del plato
  /// en general se envía el precio del plato o insumo
  /// si es un plato preparado, se envía el código de la categoría del plato
  Future<bool> submit() async {
    isSaving = true;
    notifyListeners();

    final stock = double.tryParse(stockCtrl.text.trim()) ?? 0;
    final totalCost = double.tryParse(compraCtrl.text.trim()) ?? 0;
    // evita división por cero
    final double unitCost = stock > 0 ? totalCost / stock : 0;

    final dto = MenuRequest(
      platos: nameCtrl.text.trim(),
      descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      precio: double.tryParse(priceCtrl.text.trim()) ?? 0,
      categoriaCodigo: selectedCategoria ?? '',
      esPreparado: esPreparado ? 'A' : 'I',
      receta: esPreparado ? detalles : null,
      insumo:
          !esPreparado
              ? InsumoRequest(
                unidadMedida: unitCtrl.text.trim(),
                stockActual: stock,
                compraUnidad: unitCost,
              )
              : null,
    );

    final file =
        (!kIsWeb && pickedImage != null) ? File(pickedImage!.path) : null;

    final ok = await MenuService.agregarMenu(
      dto,
      imageFile: file, // <- ya no como posicional
      imageBytes: kIsWeb ? imageData : null,
      imageName: kIsWeb ? pickedImage?.name : null,
    );

    isSaving = false;
    notifyListeners();
    return ok;
  }
}
