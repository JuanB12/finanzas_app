import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/gasto.dart';
import 'package:finanzas_app/models/presupuesto.dart';
import 'package:finanzas_app/models/quincena.dart';

void main() {
  // disponible: 370.300
  const quincena = Quincena(
    ingresos: 797000,
    gastosFijos: [
      GastoFijo(nombre: 'Plan hogar - Claro', monto: 150000),
      GastoFijo(nombre: 'Gimnasio', monto: 100000),
      GastoFijo(nombre: 'Disney +', monto: 22000),
      GastoFijo(nombre: 'CelularPersonal', monto: 35000),
      GastoFijo(nombre: 'CelularTrabajo', monto: 40000),
    ],
    porcentajeAhorro: 10,
  );

  // Quincena del 30 oct. al 13 nov.: quedan 3 días
  final hoy = DateTime(2026, 11, 10, 9, 30);

  ResumenDelDia resumen(List<Gasto> gastos) =>
      resumenDelDia(quincena: quincena, gastos: gastos, hoy: hoy, festivos: {});

  test('Sin gastos, el disponible se reparte entre los días que faltan', () {
    final r = resumen([]);
    expect(r.diasRestantes, 3);
    expect(r.limiteHoy, 123433); // 370.300 / 3
    expect(r.quedaHoy, 123433);
    expect(r.disponibleRestante, 370300);
  });

  test('Lo gastado antes de hoy baja el límite de hoy', () {
    final r = resumen([
      Gasto(
        descripcion: 'Mercado',
        monto: 100000,
        fecha: DateTime(2026, 11, 2),
      ),
    ]);
    expect(r.limiteHoy, 90100); // (370.300 - 100.000) / 3
  });

  test('Lo gastado hoy se descuenta de lo que te queda hoy, no del límite', () {
    final r = resumen([
      Gasto(
        descripcion: 'Mercado',
        monto: 100000,
        fecha: DateTime(2026, 11, 2),
      ),
      Gasto(
        descripcion: 'Café',
        monto: 20000,
        fecha: DateTime(2026, 11, 10, 8),
      ),
    ]);
    expect(r.limiteHoy, 90100);
    expect(r.gastadoHoy, 20000);
    expect(r.quedaHoy, 70100);
    expect(r.disponibleRestante, 250300);
  });

  test('Un gasto del mismo día de pago cuenta en la quincena nueva', () {
    final r = resumen([
      Gasto(
        descripcion: 'Almuerzo',
        monto: 30000,
        fecha: DateTime(2026, 10, 30),
      ),
    ]);
    expect(r.limiteHoy, 113433); // (370.300 - 30.000) / 3
  });

  test('Los gastos de la quincena pasada no cuentan', () {
    final r = resumen([
      Gasto(descripcion: 'Cine', monto: 50000, fecha: DateTime(2026, 10, 29)),
    ]);
    expect(r.limiteHoy, 123433);
  });

  test('Si te pasaste de la quincena, el límite es 0 y se ve el hueco', () {
    final r = resumen([
      Gasto(descripcion: 'Viaje', monto: 400000, fecha: DateTime(2026, 11, 5)),
    ]);
    expect(r.limiteHoy, 0);
    expect(r.disponibleRestante, -29700);
  });
}
