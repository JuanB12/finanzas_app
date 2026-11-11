import 'models/quincena.dart';

// Valores iniciales hasta que exista la base de datos.
// Los días de cobro y el valor de Netflix son aproximados: se ajustan en ⚙️
const nombreInicial = 'Juan';

const quincenaInicial = Quincena(
  ingresos: 797000,
  gastosFijos: [
    GastoFijo(nombre: 'Plan hogar - Claro', monto: 150000, diaCobro: 5),
    GastoFijo(nombre: 'Gimnasio', monto: 100000, diaCobro: 1),
    GastoFijo(nombre: 'Disney+', monto: 22000, diaCobro: 12),
    GastoFijo(nombre: 'Netflix', monto: 26900, diaCobro: 20),
    GastoFijo(nombre: 'Celular personal', monto: 35000, diaCobro: 18),
    GastoFijo(nombre: 'Celular trabajo', monto: 40000, diaCobro: 25),
  ],
  porcentajeAhorro: 10,
  porcentajeImprevistos: 5,
);
