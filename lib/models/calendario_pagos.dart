bool esDiaHabil(DateTime dia, Set<DateTime> festivos) {
  return dia.weekday != DateTime.saturday &&
      dia.weekday != DateTime.sunday &&
      !festivos.contains(dia);
}

DateTime diaHabilAnterior(DateTime dia, Set<DateTime> festivos) {
  var d = dia;
  while (!esDiaHabil(d, festivos)) {
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return d;
}

// El día 0 del mes siguiente es el último de este mes
DateTime ultimoDiaDelMes(int anio, int mes) => DateTime(anio, mes + 1, 0);

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

// Día en que empezó la quincena actual (puede ser hoy)
DateTime pagoAnterior(DateTime hoy, {required Set<DateTime> festivos}) {
  final dia = soloFecha(hoy);
  final candidatos = [
    ultimoDiaDelMes(dia.year, dia.month),
    DateTime(dia.year, dia.month, 15),
    ultimoDiaDelMes(dia.year, dia.month - 1),
  ];
  for (final fecha in candidatos) {
    final pago = diaHabilAnterior(fecha, festivos);
    if (!pago.isAfter(dia)) return pago;
  }
  throw StateError('No se encontró el pago anterior');
}

// Si hoy pagaron, devuelve el siguiente pago
DateTime proximoPago(DateTime hoy, {required Set<DateTime> festivos}) {
  final dia = soloFecha(hoy);

  final candidatos = [
    DateTime(dia.year, dia.month, 15),
    ultimoDiaDelMes(dia.year, dia.month),
  ];
  for (final fecha in candidatos) {
    final pago = diaHabilAnterior(fecha, festivos);
    if (pago.isAfter(dia)) return pago;
  }

  return diaHabilAnterior(DateTime(dia.year, dia.month + 1, 15), festivos);
}

// Cuenta hoy, no cuenta el día de pago
int diasHastaPago(DateTime hoy, {required Set<DateTime> festivos}) {
  return diasEntre(hoy, proximoPago(hoy, festivos: festivos));
}

// En UTC para que un cambio de horario no dañe la resta
int diasEntre(DateTime desde, DateTime hasta) {
  final a = DateTime.utc(desde.year, desde.month, desde.day);
  final b = DateTime.utc(hasta.year, hasta.month, hasta.day);
  return b.difference(a).inDays;
}
