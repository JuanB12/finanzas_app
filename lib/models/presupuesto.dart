import 'calendario_pagos.dart';
import 'gasto.dart';
import 'quincena.dart';

class ResumenDelDia {
  final DateTime inicio;
  final DateTime fin;
  final int diasQuincena;
  final int diasRestantes;
  final int disponibleQuincena;
  final int limiteHoy;
  final int gastadoHoy;
  final int apartado; // gastos programados de esta quincena
  final int disponibleRestante; // negativo si te pasaste

  const ResumenDelDia({
    required this.inicio,
    required this.fin,
    required this.diasQuincena,
    required this.diasRestantes,
    required this.disponibleQuincena,
    required this.limiteHoy,
    required this.gastadoHoy,
    required this.apartado,
    required this.disponibleRestante,
  });

  int get quedaHoy => limiteHoy - gastadoHoy;

  int get porcentajeRestante {
    if (disponibleQuincena <= 0 || disponibleRestante <= 0) return 0;
    return disponibleRestante * 100 ~/ disponibleQuincena;
  }

  // Vas bien si te queda más plata que tiempo
  bool get buenRitmo =>
      disponibleRestante * diasQuincena >= diasRestantes * disponibleQuincena;
}

// Lo gastado hoy no mueve el límite de hoy, solo lo que te queda.
// Los programados se apartan de toda la quincena, no del día.
ResumenDelDia resumenDelDia({
  required Quincena quincena,
  required List<Gasto> gastos,
  required DateTime hoy,
  required Set<DateTime> festivos,
}) {
  final dia = soloFecha(hoy);
  final inicio = pagoAnterior(dia, festivos: festivos);
  final fin = proximoPago(dia, festivos: festivos);

  var gastadoAntes = 0;
  var gastadoHoy = 0;
  var apartado = 0;
  for (final gasto in gastos) {
    final fecha = soloFecha(gasto.fecha);
    if (fecha.isBefore(inicio) || !fecha.isBefore(fin)) continue;

    if (gasto.programado || fecha.isAfter(dia)) {
      apartado += gasto.monto;
    } else if (fecha == dia) {
      gastadoHoy += gasto.monto;
    } else {
      gastadoAntes += gasto.monto;
    }
  }

  final dias = diasHastaPago(dia, festivos: festivos);
  final paraRepartir = quincena.disponible - gastadoAntes - apartado;

  return ResumenDelDia(
    inicio: inicio,
    fin: fin,
    diasQuincena: diasEntre(inicio, fin),
    diasRestantes: dias,
    disponibleQuincena: quincena.disponible,
    limiteHoy: paraRepartir > 0 ? paraRepartir ~/ dias : 0,
    gastadoHoy: gastadoHoy,
    apartado: apartado,
    disponibleRestante: paraRepartir - gastadoHoy,
  );
}
