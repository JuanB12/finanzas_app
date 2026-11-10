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

  /// Lo que se separa para ahorrar apenas llega la quincena.
  int get ahorro => ingresos * porcentajeAhorro ~/ 100;

  /// La suma de todos los gastos fijos.
  int get totalGastosFijos =>
      gastosFijos.fold(0, (suma, gasto) => suma + gasto.monto);

  /// Lo que queda para gastar después del ahorro y los gastos fijos.
  int get disponible => ingresos - ahorro - totalGastosFijos;

  /// Cuánto se puede gastar por día. Redondea hacia abajo para no pasarse.
  int limiteDiario(int diasRestantes) => disponible ~/ diasRestantes;
}
