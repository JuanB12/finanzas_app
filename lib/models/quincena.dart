class GastoFijo {
  final String nombre;
  final int monto; // Monto en COP (pesos colombianos) - Por el momento no se maneja en otra moneda, mientras no se implemente la funcionalidad de multi-moneda
  const GastoFijo({required this.nombre, required this.monto});
}

// Configuracion de la quincena del usuario
class Quincena {
  final int ingresos;
  final List<int> diasDePago; // Lista de días de pago del usuario (1-31)
  final List<GastoFijo> gastosFijos;
  final int porcentajeAhorro; // Porcentaje de ahorro del usuario (0-100)

  const Quincena({
    required this.ingresos,
    required this.diasDePago,
    required this.gastosFijos,
    required this.porcentajeAhorro,
  });
}
