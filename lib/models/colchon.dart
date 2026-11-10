class IngresoExtra {
  final String nombre;
  final int monto;
  final DateTime fecha;

  const IngresoExtra({
    required this.nombre,
    required this.monto,
    required this.fecha,
  });
}

// Prima, cesantías y demás: no se suman al límite diario
class Colchon {
  final List<IngresoExtra> ingresos;

  const Colchon({required this.ingresos});

  int get total => ingresos.fold(0, (suma, ingreso) => suma + ingreso.monto);
}
