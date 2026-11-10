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

  group('Gastos programados', () {
    final odontologo = Gasto(
      descripcion: 'Odontólogo',
      monto: 80000,
      fecha: DateTime(2026, 11, 12),
      programado: true,
    );

    test('Se apartan desde hoy y bajan el límite', () {
      final r = resumen([odontologo]);
      expect(r.apartado, 80000);
      expect(r.limiteHoy, 96766); // (370.300 - 80.000) / 3
    });

    test('Un gasto con fecha futura se aparta aunque no esté marcado', () {
      final r = resumen([
        Gasto(descripcion: 'Taxi', monto: 80000, fecha: DateTime(2026, 11, 12)),
      ]);
      expect(r.limiteHoy, 96766);
    });

    test('Los de la próxima quincena no afectan esta', () {
      final r = resumen([
        Gasto(
          descripcion: 'Arriendo',
          monto: 500000,
          fecha: DateTime(2026, 11, 20),
          programado: true,
        ),
      ]);
      expect(r.apartado, 0);
      expect(r.limiteHoy, 123433);
    });

    test('El día del gasto no se descuenta dos veces', () {
      final r = resumenDelDia(
        quincena: quincena,
        gastos: [odontologo],
        hoy: DateTime(2026, 11, 12),
        festivos: {},
      );
      expect(r.diasRestantes, 1);
      expect(r.limiteHoy, 290300);
      expect(r.gastadoHoy, 0);
      expect(r.quedaHoy, 290300);
    });

    test('Uno que ya pasó tampoco se descuenta dos veces', () {
      final r = resumen([
        Gasto(
          descripcion: 'Examen',
          monto: 80000,
          fecha: DateTime(2026, 11, 3),
          programado: true,
        ),
      ]);
      expect(r.limiteHoy, 96766);
      expect(r.disponibleRestante, 290300);
    });
  });

  group('Ritmo de gasto', () {
    test('La quincena va del último pago al próximo', () {
      final r = resumen([]);
      expect(r.inicio, DateTime(2026, 10, 30));
      expect(r.fin, DateTime(2026, 11, 13));
      expect(r.diasQuincena, 14);
    });

    test('Sin gastos queda el 100% y vas bien', () {
      final r = resumen([]);
      expect(r.porcentajeRestante, 100);
      expect(r.buenRitmo, isTrue);
    });

    test('Si queda menos plata que tiempo, vas rápido', () {
      // quedan 3 de 14 días (21%) pero solo el 5% de la plata
      final r = resumen([
        Gasto(
          descripcion: 'Viaje',
          monto: 350000,
          fecha: DateTime(2026, 11, 5),
        ),
      ]);
      expect(r.porcentajeRestante, 5);
      expect(r.buenRitmo, isFalse);
    });

    test('Si te pasaste, el porcentaje no baja de 0', () {
      final r = resumen([
        Gasto(
          descripcion: 'Viaje',
          monto: 400000,
          fecha: DateTime(2026, 11, 5),
        ),
      ]);
      expect(r.porcentajeRestante, 0);
    });
  });

  group('Gastos de la quincena', () {
    test('Un mercado de la quincena no se come el límite de hoy', () {
      final r = resumen([
        Gasto(
          descripcion: 'Mercado',
          monto: 160000,
          fecha: hoy,
          deQuincena: true,
        ),
      ]);
      expect(r.gastadoHoy, 0);
      expect(r.apartado, 160000);
      expect(r.limiteHoy, 70100); // (370.300 - 160.000) / 3
      expect(r.quedaHoy, 70100);
    });
  });

  group('Cómo vas hoy', () {
    test('Sin pasarte, vas bien', () {
      expect(resumen([]).estadoHoy, EstadoHoy.bien);
    });

    test('Si te pasaste hoy pero la quincena va bien, no es tan grave', () {
      final r = resumen([
        Gasto(descripcion: 'Salida', monto: 130000, fecha: hoy),
      ]);
      expect(r.estadoHoy, EstadoHoy.pasadoPeroVasBien);
    });

    test('Si te pasaste hoy y vas rápido, sí es grave', () {
      final r = resumen([
        Gasto(
          descripcion: 'Viaje',
          monto: 300000,
          fecha: DateTime(2026, 11, 5),
        ),
        Gasto(descripcion: 'Salida', monto: 30000, fecha: hoy),
      ]);
      expect(r.estadoHoy, EstadoHoy.pasado);
    });
  });

  test('Sabe a qué quincena pertenece cada fecha', () {
    final r = resumen([]); // quincena del 30 oct. al 12 nov.
    expect(r.cualQuincena(DateTime(2026, 10, 29)), CualQuincena.pasada);
    expect(r.cualQuincena(DateTime(2026, 10, 30)), CualQuincena.actual);
    expect(r.cualQuincena(DateTime(2026, 11, 12, 23)), CualQuincena.actual);
    expect(r.cualQuincena(DateTime(2026, 11, 13)), CualQuincena.proxima);
  });
}
