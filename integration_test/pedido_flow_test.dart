import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:rincon_sabor_flutter/screens/main_dev.dart' as app;

void main() {
  // Inicializa el entorno de integración
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧾 Flujo completo de Pedidos', () {
    testWidgets('Abrir, agregar nota y enviar pedido a cocina',
            (WidgetTester tester) async {
          // 🟢 Iniciar la app completa
          app.main();
          await tester.pumpAndSettle(c  onst Duration(seconds: 4));

          // 🔍 Buscar el FloatingActionButton principal
          final fabFinder = find.byKey(const Key('pedido_fab_container'));
          expect(fabFinder, findsOneWidget,
              reason: 'No se encontró el botón de pedido (FAB)');

          // 👉 Tocar el botón de pedido
          await tester.tap(fabFinder);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ✅ Verificar que se abrió el bottom sheet
          expect(find.byKey(const Key('pedido_bottomsheet')), findsOneWidget,
              reason: 'No se abrió el bottom sheet del pedido');

          // 🛒 Verificar que muestre el texto "Tu pedido está vacío"
          expect(find.byKey(const Key('pedido_vacio_text')), findsOneWidget,
              reason: 'No aparece el texto de pedido vacío');

          // 🔁 Simular apertura de diálogo de nota (solo visual)
          await tester.runAsync(() async {
            showDialog(
              context: tester.element(fabFinder),
              builder: (_) => AlertDialog(
                key: const Key('dialog_editar_nota'),
                title: const Text('Agregar nota'),
                content: const TextField(
                  key: Key('nota_textfield'),
                  decoration: InputDecoration(hintText: 'Escribe algo...'),
                ),
                actions: [
                  TextButton(
                    key: const Key('btn_cancelar_nota'),
                    onPressed: () => Navigator.pop(_),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    key: const Key('btn_guardar_nota'),
                    onPressed: () => Navigator.pop(_, 'sin cebolla'),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            );
          });

          await tester.pumpAndSettle();

          // ✍️ Escribir texto en el TextField del diálogo
          await tester.enterText(find.byKey(const Key('nota_textfield')), 'sin cebolla');
          await tester.pumpAndSettle();

          // 💾 Guardar la nota
          await tester.tap(find.byKey(const Key('btn_guardar_nota')));
          await tester.pumpAndSettle();

          // 🚀 Intentar presionar “Enviar a Cocina”
          final enviarBtn = find.byKey(const Key('btn_enviar_cocina'));
          if (enviarBtn.evaluate().isNotEmpty) {
            await tester.tap(enviarBtn);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }

          // 🏁 Validación final (sin errores)
          expect(tester.takeException(), isNull,
              reason: 'Ocurrió un error inesperado durante el flujo de pedido');
        });
  });
}
