import 'calendario_pagos.dart';
import 'gasto.dart';
import 'quincena.dart';

enum EstadoHoy { bien, pasadoPeroVasBien, pasado }

enum CualQuincena { pasada, actual, proxima }

class ResumenDelDia {
  final DateTime inicio;
  final DateTime fin;
  final int diasQuincena;
  final int diasRestantes;
  final int disponibleQuincena;
  final int limiteHoy;
  final int gastadoHoy;
  final int apartado; // programados y gastos de la quincena
  final int disponibleRestante; // negativo si te pasaste
  final int fondoImprevistos;
  final int imprevistosUsados;

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
    this.fondoImprevistos = 0,
    this.imprevistosUsados = 0,
  });

  int get imprevistosRestantes => fondoImprevistos > imprevistosUsados
      ? fondoImprevistos - imprevistosUsados
      : 0;

  int get quedaHoy => limiteHoy - gastadoHoy;

  int get porcentajeRestante {
    if (disponibleQuincena <= 0 || disponibleRestante <= 0) return 0;
    return disponibleRestante * 100 ~/ disponibleQuincena;
  }

  EstadoHoy get estadoHoy {
    if (quedaHoy >= 0) return EstadoHoy.bien;
    return buenRitmo ? EstadoHoy.pasadoPeroVasBien : EstadoHoy.pasado;
  }

  CualQuincena cualQuincena(DateTime fecha) {
    final dia = soloFecha(fecha);
    if (dia.isBefore(inicio)) return CualQuincena.pasada;
    if (dia.isBefore(fin)) return CualQuincena.actual;
    return CualQuincena.proxima;
  }

  // Vas bien si te queda más plata que tiempo
  bool get buenRitmo =>
      disponibleRestante * diasQuincena >= diasRestantes * disponibleQuincena;
}

// Lo gastado hoy no mueve el límite de hoy, solo lo que te queda.
// Los programados y los de la quincena se apartan de toda la quincena, no del día.
ResumenDelDia resumenDelDia({
  required Quincena quincena,
  required List<Gasto> gastos,
  required DateTime hoy,
  required Set<DateTime> festivos,
}) {
  final dia = soloFecha(hoy);
  final forma = quincena.formaDePago;
  final inicio = pagoAnterior(dia, festivos: festivos, forma: forma);
  final fin = proximoPago(dia, festivos: festivos, forma: forma);

  var gastadoAntes = 0;
  var gastadoHoy = 0;
  var apartado = 0;
  var imprevistos = 0;
  for (final gasto in gastos) {
    final fecha = soloFecha(gasto.fecha);
    if (fecha.isBefore(inicio) || !fecha.isBefore(fin)) continue;

    if (gasto.imprevisto) {
      imprevistos += gasto.monto;
    } else if (gasto.programado || gasto.deQuincena || fecha.isAfter(dia)) {
      apartado += gasto.monto;
    } else if (fecha == dia) {
      gastadoHoy += gasto.monto;
    } else {
      gastadoAntes += gasto.monto;
    }
  }

  final dias = diasHastaPago(dia, festivos: festivos, forma: forma);
  // Lo que el fondo de imprevistos no alcanza a cubrir sale de la quincena
  final fondo = quincena.fondoImprevistos;
  final sinCubrir = imprevistos > fondo ? imprevistos - fondo : 0;
  final disponible = quincena.disponibleEntre(inicio, fin);
  final paraRepartir = disponible - gastadoAntes - apartado - sinCubrir;

  return ResumenDelDia(
    inicio: inicio,
    fin: fin,
    diasQuincena: diasEntre(inicio, fin),
    diasRestantes: dias,
    disponibleQuincena: disponible,
    limiteHoy: paraRepartir > 0 ? paraRepartir ~/ dias : 0,
    gastadoHoy: gastadoHoy,
    apartado: apartado,
    disponibleRestante: paraRepartir - gastadoHoy,
    fondoImprevistos: fondo,
    imprevistosUsados: imprevistos,
  );
}

typedef Periodo = ({DateTime inicio, DateTime fin, int fijos, int disponible});

// El periodo actual y los siguientes, con los fijos que caen en cada uno
List<Periodo> proximosPeriodos({
  required Quincena quincena,
  required DateTime hoy,
  required Set<DateTime> festivos,
  int cantidad = 2,
}) {
  final forma = quincena.formaDePago;
  final periodos = <Periodo>[];
  var inicio = pagoAnterior(hoy, festivos: festivos, forma: forma);
  for (var i = 0; i < cantidad; i++) {
    final fin = proximoPago(inicio, festivos: festivos, forma: forma);
    periodos.add((
      inicio: inicio,
      fin: fin,
      fijos: quincena.gastosFijosEntre(inicio, fin),
      disponible: quincena.disponibleEntre(inicio, fin),
    ));
    inicio = fin;
  }
  return periodos;
}
