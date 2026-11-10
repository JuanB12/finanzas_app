enum MedioPago {
  nequi('Nequi'),
  daviplata('Daviplata'),
  efectivo('Efectivo');

  const MedioPago(this.nombre);
  final String nombre;
}

class Gasto {
  final String descripcion;
  final int monto;
  final DateTime fecha;
  final bool programado;
  final bool deQuincena; // ej. el mercado: es para toda la quincena
  final MedioPago medioPago;

  const Gasto({
    required this.descripcion,
    required this.monto,
    required this.fecha,
    this.programado = false,
    this.deQuincena = false,
    this.medioPago = MedioPago.efectivo,
  });
}
