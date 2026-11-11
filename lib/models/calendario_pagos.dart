import 'forma_de_pago.dart';

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

DateTime _diaDePago(int anio, int mes, int dia) {
  final ultimo = ultimoDiaDelMes(anio, mes).day;
  return DateTime(anio, mes, dia > ultimo ? ultimo : dia);
}

// Pagos reales (ya corridos a día hábil) de dos meses antes a dos después
List<DateTime> _pagosCerca(
  DateTime dia,
  FormaDePago forma,
  Set<DateTime> festivos,
) {
  return [
    for (var mes = dia.month - 2; mes <= dia.month + 2; mes++)
      for (final d in forma.diasDePago)
        diaHabilAnterior(
          _diaDePago(
            DateTime(dia.year, mes).year,
            DateTime(dia.year, mes).month,
            d,
          ),
          festivos,
        ),
  ]..sort();
}

// Día en que empezó el periodo actual (puede ser hoy)
DateTime pagoAnterior(
  DateTime hoy, {
  required Set<DateTime> festivos,
  FormaDePago forma = const FormaDePago.quincenal(),
}) {
  final dia = soloFecha(hoy);
  return _pagosCerca(
    dia,
    forma,
    festivos,
  ).lastWhere((pago) => !pago.isAfter(dia));
}

// Si hoy pagaron, devuelve el siguiente pago
DateTime proximoPago(
  DateTime hoy, {
  required Set<DateTime> festivos,
  FormaDePago forma = const FormaDePago.quincenal(),
}) {
  final dia = soloFecha(hoy);
  return _pagosCerca(dia, forma, festivos).firstWhere((p) => p.isAfter(dia));
}

// Cuenta hoy, no cuenta el día de pago
int diasHastaPago(
  DateTime hoy, {
  required Set<DateTime> festivos,
  FormaDePago forma = const FormaDePago.quincenal(),
}) {
  return diasEntre(hoy, proximoPago(hoy, festivos: festivos, forma: forma));
}

// En UTC para que un cambio de horario no dañe la resta
int diasEntre(DateTime desde, DateTime hasta) {
  final a = DateTime.utc(desde.year, desde.month, desde.day);
  final b = DateTime.utc(hasta.year, hasta.month, hasta.day);
  return b.difference(a).inDays;
}
