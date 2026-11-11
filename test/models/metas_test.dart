import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/gasto.dart';
import 'package:finanzas_app/models/metas.dart';
import 'package:finanzas_app/models/quincena.dart';

void main() {
  final hoy = DateTime(2026, 11, 10);
  // Quincena actual: 30 oct. al 12 nov.
  final inicio = DateTime(2026, 10, 30);
  final fin = DateTime(2026, 11, 13);

  const viaje = Meta(
    nombre: 'Viaje a Cartagena',
    objetivo: 1200000,
    ahorrado: 450000,
    aporte: 150000,
  );

  group('Metas de ahorro', () {
    test('Sabe cuánto falta y cuántos aportes necesita', () {
      expect(viaje.faltante, 750000);
      expect(viaje.aportesRestantes, 5);
      expect(viaje.porcentaje, 37);
      expect(viaje.cumplida, isFalse);
    });

    test('Si el último aporte no es completo, igual cuenta como uno', () {
      const moto = Meta(nombre: 'Moto', objetivo: 1000000, aporte: 300000);
      expect(moto.aportesRestantes, 4); // 300 + 300 + 300 + 100
    });

    test('Sin aporte no hay fecha estimada', () {
      const sueno = Meta(nombre: 'Sueño', objetivo: 500000);
      expect(sueno.aportesRestantes, isNull);
      expect(
        fechaEstimada(
          meta: sueno,
          quincena: const Quincena(
            ingresos: 797000,
            gastosFijos: [],
            porcentajeAhorro: 10,
          ),
          hoy: hoy,
          festivos: {},
        ),
        isNull,
      );
    });

    test('Una meta cumplida no necesita más aportes', () {
      const lista = Meta(
        nombre: 'Celular',
        objetivo: 800000,
        ahorrado: 800000,
        aporte: 100000,
      );
      expect(lista.cumplida, isTrue);
      expect(lista.aportesRestantes, 0);
      expect(lista.porcentaje, 100);
    });

    test('La fecha estimada es el día de pago del último aporte', () {
      // Próximos pagos: 13 nov, 30 nov, 15 dic, 31 dic y 15 ene
      final fecha = fechaEstimada(
        meta: viaje,
        quincena: const Quincena(
          ingresos: 797000,
          gastosFijos: [],
          porcentajeAhorro: 10,
        ),
        hoy: hoy,
        festivos: {},
      );
      expect(fecha, DateTime(2027, 1, 15));
    });

    test('Los aportes a metas se separan del disponible, como el ahorro', () {
      final q = Quincena(
        ingresos: 797000,
        gastosFijos: const [],
        porcentajeAhorro: 10,
        metas: const [viaje],
      );
      expect(q.aportesMetas, 150000);
      // 797.000 - 79.700 - 150.000
      expect(q.disponibleEntre(inicio, fin), 567300);
    });

    test('Una meta cumplida ya no aparta plata', () {
      const lista = Meta(
        nombre: 'Celular',
        objetivo: 800000,
        ahorrado: 800000,
        aporte: 100000,
      );
      final q = Quincena(
        ingresos: 797000,
        gastosFijos: const [],
        porcentajeAhorro: 10,
        metas: const [lista],
      );
      expect(q.aportesMetas, 0);
    });
  });

  group('Topes por categoría', () {
    const domicilios = Tope(categoria: 'Domicilios', maximo: 80000);

    Gasto gasto(int monto, DateTime fecha, [String c = 'Domicilios']) =>
        Gasto(descripcion: c, monto: monto, fecha: fecha);

    test('Suma solo esa categoría dentro del periodo', () {
      final estado = estadoTope(
        tope: domicilios,
        gastos: [
          gasto(30000, DateTime(2026, 11, 2)),
          gasto(34000, DateTime(2026, 11, 9)),
          gasto(50000, DateTime(2026, 11, 9), 'Mercado'),
          gasto(40000, DateTime(2026, 10, 29)), // quincena pasada
        ],
        inicio: inicio,
        fin: fin,
      );
      expect(estado.usado, 64000);
      expect(estado.porcentaje, 80);
      expect(estado.nivel, NivelTope.cerca);
    });

    test('Por debajo del 80% va bien', () {
      final estado = estadoTope(
        tope: domicilios,
        gastos: [gasto(20000, DateTime(2026, 11, 2))],
        inicio: inicio,
        fin: fin,
      );
      expect(estado.nivel, NivelTope.bien);
    });

    test('Por encima del tope ya se pasó', () {
      final estado = estadoTope(
        tope: domicilios,
        gastos: [gasto(90000, DateTime(2026, 11, 2))],
        inicio: inicio,
        fin: fin,
      );
      expect(estado.nivel, NivelTope.pasado);
      expect(estado.restante, -10000);
    });

    test('Se puede simular un gasto que todavía no se registra', () {
      final estado = estadoTope(
        tope: domicilios,
        gastos: [gasto(50000, DateTime(2026, 11, 2))],
        inicio: inicio,
        fin: fin,
        extra: 15000,
      );
      expect(estado.usado, 65000);
      expect(estado.nivel, NivelTope.cerca);
    });
  });
}
