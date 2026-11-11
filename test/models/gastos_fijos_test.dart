import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/presupuesto.dart';
import 'package:finanzas_app/models/quincena.dart';

void main() {
  // Quincena del 30 oct. al 12 nov. y la siguiente del 13 al 29 nov.
  final estaInicio = DateTime(2026, 10, 30);
  final estaFin = DateTime(2026, 11, 13);
  final proximaFin = DateTime(2026, 11, 30);

  const gimnasio = GastoFijo(nombre: 'Gimnasio', monto: 100000, diaCobro: 5);
  const disney = GastoFijo(nombre: 'Disney+', monto: 22000, diaCobro: 20);

  const quincena = Quincena(
    ingresos: 797000,
    gastosFijos: [gimnasio, disney],
    porcentajeAhorro: 10,
  );

  group('Día de cobro', () {
    test('Un gasto mensual solo cae en la quincena de su día de cobro', () {
      expect(gimnasio.seCobraEntre(estaInicio, estaFin), isTrue);
      expect(gimnasio.seCobraEntre(estaFin, proximaFin), isFalse);
      expect(disney.seCobraEntre(estaInicio, estaFin), isFalse);
      expect(disney.seCobraEntre(estaFin, proximaFin), isTrue);
    });

    test('Sin día de cobro, se descuenta en todos los periodos', () {
      const transporte = GastoFijo(nombre: 'Transporte', monto: 60000);
      expect(transporte.seCobraEntre(estaInicio, estaFin), isTrue);
      expect(transporte.seCobraEntre(estaFin, proximaFin), isTrue);
    });

    test('El día 31 en un mes de 30 días se cobra el 30', () {
      const arriendo = GastoFijo(
        nombre: 'Arriendo',
        monto: 500000,
        diaCobro: 31,
      );
      // El 30 de nov. es día de pago: ya es de la quincena siguiente
      expect(arriendo.seCobraEntre(estaFin, proximaFin), isFalse);
      expect(arriendo.seCobraEntre(proximaFin, DateTime(2026, 12, 15)), isTrue);
    });

    test('Cada quincena descuenta solo los fijos que le tocan', () {
      expect(quincena.gastosFijosEntre(estaInicio, estaFin), 100000);
      expect(quincena.gastosFijosEntre(estaFin, proximaFin), 22000);
      // 797.000 - 79.700 - 100.000
      expect(quincena.disponibleEntre(estaInicio, estaFin), 617300);
    });
  });

  test('El límite del día usa solo los fijos de esta quincena', () {
    final r = resumenDelDia(
      quincena: quincena,
      gastos: [],
      hoy: DateTime(2026, 11, 10),
      festivos: {},
    );
    expect(r.disponibleQuincena, 617300);
    expect(r.limiteHoy, 205766); // 617.300 / 3
  });

  test('Muestra los próximos periodos con sus fijos', () {
    final periodos = proximosPeriodos(
      quincena: quincena,
      hoy: DateTime(2026, 11, 10),
      festivos: {},
    );
    expect(periodos.length, 2);
    expect(periodos[0].inicio, estaInicio);
    expect(periodos[0].fijos, 100000);
    expect(periodos[1].inicio, estaFin);
    expect(periodos[1].fijos, 22000);
    expect(periodos[1].disponible, 695300); // 797.000 - 79.700 - 22.000
  });
}
