/// Un día es hábil si no es sábado, ni domingo, ni festivo.
bool esDiaHabil(DateTime dia, Set<DateTime> festivos) {
  return dia.weekday != DateTime.saturday &&
      dia.weekday != DateTime.sunday &&
      !festivos.contains(dia);
}

/// Si el día no es hábil, retrocede hasta encontrar el día hábil anterior.
DateTime diaHabilAnterior(DateTime dia, Set<DateTime> festivos) {
  var d = dia;
  while (!esDiaHabil(d, festivos)) {
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return d;
}

/// El día 0 del mes siguiente es el último día de este mes (28, 29, 30 o 31).
DateTime ultimoDiaDelMes(int anio, int mes) => DateTime(anio, mes + 1, 0);

/// La fecha real del próximo pago (15 o fin de mes, ajustada a día hábil).
/// Si hoy es día de pago, devuelve el siguiente: hoy ya llegó la plata.
DateTime proximoPago(DateTime hoy, {required Set<DateTime> festivos}) {
  final dia = DateTime(hoy.year, hoy.month, hoy.day); // sin horas ni minutos

  final candidatos = [
    DateTime(dia.year, dia.month, 15),
    ultimoDiaDelMes(dia.year, dia.month),
  ];
  for (final fecha in candidatos) {
    final pago = diaHabilAnterior(fecha, festivos);
    if (pago.isAfter(dia)) return pago;
  }

  // Ya pasaron los dos pagos de este mes: toca el 15 del mes siguiente.
  return diaHabilAnterior(DateTime(dia.year, dia.month + 1, 15), festivos);
}

/// Cuántos días hay para gastar: cuenta hoy, pero no el día de pago.
int diasHastaPago(DateTime hoy, {required Set<DateTime> festivos}) {
  final pago = proximoPago(hoy, festivos: festivos);
  // En UTC no hay cambios de hora, así la resta siempre da días completos.
  final desde = DateTime.utc(hoy.year, hoy.month, hoy.day);
  final hasta = DateTime.utc(pago.year, pago.month, pago.day);
  return hasta.difference(desde).inDays;
}
