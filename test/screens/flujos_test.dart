import 'package:finanzas_app/estado/finanzas.dart';
import 'package:finanzas_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Martes 10 nov. 2026: quincena del 30 oct. al 12 nov. (quedan 3 días).
// Fijos que caen en ella: gimnasio (1), Claro (5) y Disney+ (12) = $272.000
// Disponible: 797.000 - 79.700 - 39.850 - 272.000 = 405.450 → $135.150 por día
final hoy = DateTime(2026, 11, 10, 10);

Widget app() => FinanzasScope(
  finanzas: Finanzas(ahora: () => hoy),
  child: const FinanzasApp(),
);

Future<void> abrir(WidgetTester tester) async {
  // Pantalla de iPhone: 390 x 844
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app());
}

Future<void> verYTocar(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> registrarGasto(
  WidgetTester tester,
  List<String> teclas, {
  bool imprevisto = false,
}) async {
  await tester.tap(find.byTooltip('Agregar gasto'));
  await tester.pumpAndSettle();
  for (final t in teclas) {
    await verYTocar(tester, find.byKey(ValueKey('tecla-$t')));
  }
  if (imprevisto) await verYTocar(tester, find.text('Es un imprevisto'));
  await tester.tap(find.textContaining('Confirmar gasto'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Arranca con el límite de hoy correcto', (tester) async {
    await abrir(tester);
    expect(find.text('Hoy puedes gastar'), findsOneWidget);
    expect(find.text(r'$135.150'), findsOneWidget);
    expect(find.textContaining('Quincena · 30 oct al 12 nov'), findsOneWidget);
  });

  testWidgets('Registrar un almuerzo baja lo que queda hoy', (tester) async {
    await abrir(tester);
    await registrarGasto(tester, ['2', '0', '000']);

    expect(find.text(r'$115.150'), findsOneWidget);
    expect(find.text('Almuerzo'), findsOneWidget);
  });

  testWidgets('Un imprevisto sale del fondo y no toca el día', (tester) async {
    await abrir(tester);
    await registrarGasto(tester, ['2', '0', '000'], imprevisto: true);

    expect(find.text(r'$135.150'), findsOneWidget);
    expect(
      find.textContaining(r'te quedan $19.850 de $39.850'),
      findsOneWidget,
    );
  });

  testWidgets('Borrar un gasto y deshacerlo', (tester) async {
    await abrir(tester);
    await registrarGasto(tester, ['2', '0', '000']);

    await tester.drag(find.text('Almuerzo'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Almuerzo'), findsNothing);
    expect(find.text(r'$135.150'), findsOneWidget);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text(r'$115.150'), findsOneWidget);
  });

  testWidgets('Cambiar a pago mensual cambia el periodo', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Mi plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mensual'));
    await tester.pumpAndSettle();
    await verYTocar(tester, find.text('Guardar'));
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mes · 30 oct al 29 nov'), findsOneWidget);
  });

  testWidgets('No deja guardar sin ingreso', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Mi plan'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Ingreso por quincena'),
      '',
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Guardar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Escribe tu ingreso'), findsOneWidget);
    final guardar = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar'),
    );
    expect(guardar.onPressed, isNull);
  });

  testWidgets('Mi plan avisa los cambios sin guardar y deja descartarlos', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Mi plan'));
    await tester.pumpAndSettle();
    expect(find.text('Tienes cambios sin guardar'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Ingreso por quincena'),
      '800000',
    );
    await tester.pump();
    expect(find.text('Tienes cambios sin guardar'), findsOneWidget);

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Tienes cambios sin guardar'), findsNothing);
    expect(find.widgetWithText(TextField, '797.000'), findsOneWidget);
  });

  testWidgets('Guardar en Mi plan cambia el límite de Inicio', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Mi plan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Ingreso por quincena'),
      '1000000',
    );
    await tester.pump();
    await verYTocar(tester, find.text('Guardar'));
    expect(find.text('Guardado ✓'), findsOneWidget);

    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    // 1.000.000 - 100.000 - 50.000 - 272.000 = 578.000 / 3 días
    expect(find.text(r'$192.666'), findsOneWidget);
  });

  testWidgets('El nombre se cambia en la configuración de la app', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.byTooltip('Configuración de la app'));
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);

    await tester.tap(find.text('Nombre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Camilo');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Camilo'), findsOneWidget);
  });

  testWidgets('Con letra grande, el botón + sigue a la vista', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await abrir(tester);
    await tester.tap(find.byTooltip('Agregar gasto'));
    await tester.pumpAndSettle();
    expect(find.text('Registrar gasto'), findsOneWidget);
    // La barra de abajo tampoco se desborda
  });

  testWidgets('Ver todos lleva a Movimientos agrupados por día', (
    tester,
  ) async {
    await abrir(tester);
    await registrarGasto(tester, ['2', '0', '000']);

    await tester.tap(find.text('Ver todos (1) →'));
    await tester.pumpAndSettle();
    expect(find.text('Movimientos').last, findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Almuerzo'), findsOneWidget);
  });

  testWidgets('Buscar en Movimientos filtra la lista', (tester) async {
    await abrir(tester);
    await registrarGasto(tester, ['2', '0', '000']); // Almuerzo
    await tester.tap(find.byTooltip('Agregar gasto'));
    await tester.pumpAndSettle();
    await verYTocar(tester, find.text('Mercado'));
    for (final t in ['5', '000']) {
      await verYTocar(tester, find.byKey(ValueKey('tecla-$t')));
    }
    await tester.tap(find.textContaining('Confirmar gasto'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Movimientos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'merca');
    await tester.pumpAndSettle();

    expect(find.text('1 de 2 · \$5.000'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Almuerzo'), findsNothing);
  });

  testWidgets('Análisis muestra en qué se va la plata', (tester) async {
    await abrir(tester);
    await registrarGasto(tester, ['2', '0', '000']);

    await tester.tap(find.text('Análisis'));
    await tester.pumpAndSettle();
    expect(find.text('Gastado hasta hoy'), findsOneWidget);
    expect(find.text(r'$20.000'), findsWidgets);
    expect(
      find.textContaining('Tu mayor gasto es Almuerzo: 100%'),
      findsOneWidget,
    );
  });

  testWidgets('Cambiar a modo oscuro y usar la app', (tester) async {
    await abrir(tester);
    Brightness brillo() =>
        Theme.of(tester.element(find.text('Hola, Juan'))).brightness;
    expect(brillo(), Brightness.light);

    await tester.tap(find.byTooltip('Configuración de la app'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apariencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(find.text('Oscuro'), findsOneWidget); // ahora es el detalle
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(brillo(), Brightness.dark);

    // Las pantallas funcionan igual en oscuro
    await registrarGasto(tester, ['2', '0', '000']);
    expect(find.text(r'$115.150'), findsOneWidget);
    await tester.tap(find.text('Análisis'));
    await tester.pumpAndSettle();
    expect(find.text('Gastado hasta hoy'), findsOneWidget);
  });
}
