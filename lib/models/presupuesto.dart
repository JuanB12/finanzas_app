import 'calendario_pagos.dart';
import 'gasto.dart';
import 'quincena.dart';

class ResumenDelDia {
  final int diasRestantes;
  final int limiteHoy;
  final int gastadoHoy;
  final int disponibleRestante; // negativo si te pasaste

  const ResumenDelDia({
    required this.diasRestantes,
    required this.limiteHoy,
    required this.gastadoHoy,
    required this.disponibleRestante,
  });

  int get quedaHoy => limiteHoy - gastadoHoy;
}

// Lo gastado hoy no mueve el límite de hoy, solo lo que te queda
ResumenDelDia resumenDelDia({
  required Quincena quincena,
  required List<Gasto> gastos,
  required DateTime hoy,
  required Set<DateTime> festivos,
}) {
  final dia = soloFecha(hoy);
  final inicio = pagoAnterior(dia, festivos: festivos);

  var gastadoAntes = 0;
  var gastadoHoy = 0;
  for (final gasto in gastos) {
    final fecha = soloFecha(gasto.fecha);
    if (fecha.isBefore(inicio) || fecha.isAfter(dia)) continue;
    if (fecha == dia) {
      gastadoHoy += gasto.monto;
    } else {
      gastadoAntes += gasto.monto;
    }
  }

  final dias = diasHastaPago(dia, festivos: festivos);
  final paraRepartir = quincena.disponible - gastadoAntes;

  return ResumenDelDia(
    diasRestantes: dias,
    limiteHoy: paraRepartir > 0 ? paraRepartir ~/ dias : 0,
    gastadoHoy: gastadoHoy,
    disponibleRestante: paraRepartir - gastadoHoy,
  );
}
