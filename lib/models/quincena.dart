import 'calendario_pagos.dart';
import 'forma_de_pago.dart';
import 'metas.dart';

class GastoFijo {
  final String nombre;
  final int monto; // Monto en COP (pesos colombianos) - Por el momento no se maneja en otra moneda, mientras no se implemente la funcionalidad de multi-moneda
  final int? diaCobro; // null = se paga cada periodo
  const GastoFijo({required this.nombre, required this.monto, this.diaCobro});

  // El cobro del mes cae en [inicio, fin)? Se miran los meses del periodo
  bool seCobraEntre(DateTime inicio, DateTime fin) {
    final dia = diaCobro;
    if (dia == null) return true;

    for (
      var m = DateTime(inicio.year, inicio.month);
      m.isBefore(fin);
      m = DateTime(m.year, m.month + 1)
    ) {
      final ultimo = ultimoDiaDelMes(m.year, m.month).day;
      final cobro = DateTime(m.year, m.month, dia > ultimo ? ultimo : dia);
      if (!cobro.isBefore(inicio) && cobro.isBefore(fin)) return true;
    }
    return false;
  }
}

// Configuracion de la quincena del usuario
class Quincena {
  final int ingresos;
  final List<GastoFijo> gastosFijos;
  final int porcentajeAhorro; // Porcentaje de ahorro del usuario (0-100)
  final int porcentajeImprevistos;
  final FormaDePago formaDePago;
  final List<Meta> metas;
  final List<Tope> topes;

  const Quincena({
    required this.ingresos,
    required this.gastosFijos,
    required this.porcentajeAhorro,
    this.porcentajeImprevistos = 0,
    this.formaDePago = const FormaDePago.quincenal(),
    this.metas = const [],
    this.topes = const [],
  });

  /// Lo que se separa para ahorrar apenas llega la quincena.
  int get ahorro => ingresos * porcentajeAhorro ~/ 100;

  /// La suma de todos los gastos fijos.
  int get totalGastosFijos =>
      gastosFijos.fold(0, (suma, gasto) => suma + gasto.monto);

  int get fondoImprevistos => ingresos * porcentajeImprevistos ~/ 100;

  int get aportesMetas => metas.fold(0, (suma, m) => suma + m.aporteDelPeriodo);

  /// Lo que queda para gastar después del ahorro y los gastos fijos.
  /// Supone que todos los fijos caen en el mismo periodo.
  int get disponible =>
      ingresos - ahorro - totalGastosFijos - fondoImprevistos - aportesMetas;

  int gastosFijosEntre(DateTime inicio, DateTime fin) => gastosFijos
      .where((g) => g.seCobraEntre(inicio, fin))
      .fold(0, (suma, g) => suma + g.monto);

  int disponibleEntre(DateTime inicio, DateTime fin) =>
      ingresos -
      ahorro -
      fondoImprevistos -
      aportesMetas -
      gastosFijosEntre(inicio, fin);
}
