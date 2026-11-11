import 'package:finanzas_app/screens/inicio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Martes 10 nov. 2026: quincena del 30 oct. al 12 nov. (quedan 3 días).
// Fijos que caen en ella: gimnasio (1), Claro (5) y Disney+ (12) = $272.000
// Disponible: 797.000 - 79.700 - 39.850 - 272.000 = 405.450 → $135.150 por día
final hoy = DateTime(2026, 11, 10, 10);

Widget app() => MaterialApp(
  locale: const Locale('es'),
  supportedLocales: const [Locale('es')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: InicioPage(ahora: () => hoy),
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
  await tester.tap(find.text('Agregar gasto'));
  await tester.pumpAndSettle();
  for (final t in teclas) {
    await verYTocar(tester, find.byKey(ValueKey('tecla-$t')));
  }
  if (imprevisto) await verYTocar(tester, find.text('🛟 Es un imprevisto'));
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
    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mensual'));
    await tester.pumpAndSettle();
    await verYTocar(tester, find.text('Guardar'));

    expect(find.textContaining('Mes · 30 oct al 29 nov'), findsOneWidget);
  });

  testWidgets('No deja guardar sin ingreso', (tester) async {
    await abrir(tester);
    await tester.tap(find.byTooltip('Configuración'));
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

  testWidgets('Salir de ⚙️ con cambios pregunta antes de descartar', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Tu nombre'),
      'Camilo',
    );
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar los cambios?'), findsOneWidget);

    await tester.tap(find.text('Seguir editando'));
    await tester.pumpAndSettle();
    expect(find.text('Tu configuración'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Juan'), findsOneWidget);
  });

  testWidgets('Salir de ⚙️ sin cambios no pregunta nada', (tester) async {
    await abrir(tester);
    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar los cambios?'), findsNothing);
    expect(find.text('Hola, Juan'), findsOneWidget);
  });

  testWidgets('Con letra grande, Agregar gasto sigue a la vista', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await abrir(tester);
    await tester.tap(find.text('Agregar gasto'));
    await tester.pumpAndSettle();
    expect(find.text('Registrar gasto'), findsOneWidget);
  });
}
