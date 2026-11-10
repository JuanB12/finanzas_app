import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/quincena.dart';

void main() {
  const quincena = Quincena(
    ingresos: 797000,
    diasDePago: [15, 30],
    gastosFijos: [
      GastoFijo(nombre: 'Plan hogar - Claro', monto: 150000),
      GastoFijo(nombre: 'Gimnasio', monto: 100000),
      GastoFijo(nombre: 'Disney +', monto: 22000),
      GastoFijo(nombre: 'CelularPersonal', monto: 35000),
      GastoFijo(nombre: 'CelularTrabajo', monto: 40000),
    ],
    porcentajeAhorro: 10,
  );
  test('El ahorro es el 10% de los ingresos', () {
    expect(quincena.ahorro, 79700);
  });

  test('El total de gastos fijos', () {
    expect(quincena.totalGastosFijos, 347000);
  });

  test('Saldo disponible después de gastos fijos y ahorro', () {
    // 797.000 - 79.700 - 347.000
    expect(quincena.disponible, 370300);
  });

  test('El límite diario reparte el disponible entre los días que faltan', () {
    // 370.300 / 5 días = 74.060 exactos
    expect(quincena.limiteDiario(5), 74060);
  });

  test('El límite diario redondea hacia abajo para no pasarse', () {
    // 370.300 / 17 días = 21.782,35… → 21.782
    expect(quincena.limiteDiario(17), 21782);
  });
}
