import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/analisis.dart';
import 'package:finanzas_app/models/gasto.dart';

void main() {
  // Quincena del 30 oct. al 12 nov.; hoy es el 10
  final inicio = DateTime(2026, 10, 30);
  final fin = DateTime(2026, 11, 13);
  final hoy = DateTime(2026, 11, 10, 15);

  final gastos = [
    Gasto(
      descripcion: 'Mercado',
      monto: 100000,
      fecha: DateTime(2026, 11, 2),
      medioPago: MedioPago.nequi,
    ),
    Gasto(descripcion: 'Almuerzo', monto: 20000, fecha: DateTime(2026, 11, 10)),
    Gasto(
      descripcion: 'Almuerzo',
      monto: 30000,
      fecha: DateTime(2026, 11, 9),
      medioPago: MedioPago.nequi,
    ),
    // De la quincena pasada: no cuenta
    Gasto(descripcion: 'Cine', monto: 50000, fecha: DateTime(2026, 10, 29)),
    // Programado para después de hoy: todavía no se ha gastado
    Gasto(
      descripcion: 'Odontólogo',
      monto: 80000,
      fecha: DateTime(2026, 11, 12),
      programado: true,
    ),
  ];

  final a = analizar(gastos: gastos, inicio: inicio, fin: fin, hoy: hoy);

  test('Suma solo lo gastado en esta quincena hasta hoy', () {
    expect(a.total, 150000);
  });

  test('Categorías de mayor a menor, con su porcentaje', () {
    expect(a.porCategoria.map((p) => p.nombre), ['Mercado', 'Almuerzo']);
    expect(a.porCategoria[0].monto, 100000);
    expect(a.porCategoria[0].porcentaje, 66);
    expect(a.porCategoria[1].monto, 50000);
  });

  test('Medios de pago de mayor a menor, sin los que no se usaron', () {
    expect(a.porMedio.map((p) => p.nombre), ['Nequi', 'Efectivo']);
    expect(a.porMedio[0].monto, 130000);
  });

  test('Un valor por cada día, del inicio de la quincena hasta hoy', () {
    expect(a.porDia.length, 12); // 30 oct. al 10 nov.
    expect(a.porDia.first.dia, DateTime(2026, 10, 30));
    expect(a.porDia.first.monto, 0);
    expect(a.porDia[3].monto, 100000); // 2 nov.
    expect(a.porDia.last.monto, 20000);
  });

  test('Sin gastos todo queda en cero', () {
    final vacio = analizar(gastos: [], inicio: inicio, fin: fin, hoy: hoy);
    expect(vacio.total, 0);
    expect(vacio.porCategoria, isEmpty);
    expect(vacio.porDia.every((d) => d.monto == 0), isTrue);
  });
}
