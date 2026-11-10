class Gasto {
  final String descripcion;
  final int monto;
  final DateTime fecha;
  final bool programado;

  const Gasto({
    required this.descripcion,
    required this.monto,
    required this.fecha,
    this.programado = false,
  });
}
