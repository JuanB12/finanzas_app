import 'models/gasto.dart';
import 'models/quincena.dart';

// Temporal: mientras no existan la pantalla de configuración y la base de datos
const nombreUsuario = 'Juan';

const quincenaEjemplo = Quincena(
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

List<Gasto> gastosEjemplo() {
  final hoy = DateTime.now();
  return [
    Gasto(
      descripcion: 'Mercado',
      monto: 48500,
      fecha: hoy.subtract(const Duration(days: 1)),
    ),
    Gasto(descripcion: 'Café', monto: 6000, fecha: hoy),
  ];
}
