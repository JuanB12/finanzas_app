import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/gasto.dart';
import 'package:finanzas_app/models/movimientos.dart';

void main() {
  final cafe = Gasto(
    descripcion: 'Café / Snack',
    monto: 9000,
    fecha: DateTime(2026, 11, 10, 8),
  );
  final bruno = Gasto(
    descripcion: 'Remedio de Bruno',
    monto: 20000,
    fecha: DateTime(2026, 11, 9),
    medioPago: MedioPago.nequi,
  );
  final almuerzo = Gasto(
    descripcion: 'Almuerzo',
    monto: 15000,
    fecha: DateTime(2026, 11, 10, 13),
    medioPago: MedioPago.nequi,
  );
  final gastos = [bruno, cafe, almuerzo];

  group('Buscar y filtrar', () {
    test('Busca sin importar mayúsculas ni tildes', () {
      expect(filtrarGastos(gastos, texto: 'bruno'), [bruno]);
      expect(filtrarGastos(gastos, texto: 'CAFE'), [cafe]);
    });

    test('Filtra por categoría y por medio de pago', () {
      expect(filtrarGastos(gastos, categoria: 'Almuerzo'), [almuerzo]);
      expect(filtrarGastos(gastos, medio: MedioPago.nequi), [bruno, almuerzo]);
    });

    test('Los filtros se combinan', () {
      expect(filtrarGastos(gastos, texto: 'a', medio: MedioPago.efectivo), [
        cafe,
      ]);
    });
  });

  test('Agrupa por día, del más reciente al más viejo', () {
    final grupos = agruparPorDia(gastos);
    expect(grupos.length, 2);
    expect(grupos[0].dia, DateTime(2026, 11, 10));
    expect(grupos[0].total, 24000);
    expect(grupos[0].gastos, [almuerzo, cafe]); // el último registrado primero
    expect(grupos[1].dia, DateTime(2026, 11, 9));
    expect(grupos[1].total, 20000);
  });
}
