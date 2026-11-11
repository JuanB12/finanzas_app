import 'calendario_pagos.dart';
import 'gasto.dart';
import 'presupuesto.dart';
import 'quincena.dart';

// Una meta se alimenta apartando un aporte fijo cada vez que llega el pago
class Meta {
  final String nombre;
  final int objetivo;
  final int ahorrado; // lo que ya llevas
  final int aporte; // lo que apartas cada periodo

  const Meta({
    required this.nombre,
    required this.objetivo,
    this.ahorrado = 0,
    this.aporte = 0,
  });

  int get faltante => objetivo > ahorrado ? objetivo - ahorrado : 0;
  bool get cumplida => faltante == 0;
  int get porcentaje =>
      objetivo <= 0 || cumplida ? 100 : ahorrado * 100 ~/ objetivo;

  // Lo que de verdad se aparta este periodo (el último aporte puede ser menor)
  int get aporteDelPeriodo => aporte < faltante ? aporte : faltante;

  int? get aportesRestantes {
    if (cumplida) return 0;
    if (aporte <= 0) return null;
    return (faltante + aporte - 1) ~/ aporte; // redondeo hacia arriba
  }
}

// El día de pago en que se haría el último aporte
DateTime? fechaEstimada({
  required Meta meta,
  required Quincena quincena,
  required DateTime hoy,
  required Set<DateTime> festivos,
}) {
  final n = meta.aportesRestantes;
  if (n == null || n == 0) return null;
  final periodos = proximosPeriodos(
    quincena: quincena,
    hoy: hoy,
    festivos: festivos,
    cantidad: n + 1,
  );
  return periodos[n].inicio;
}

class Tope {
  final String categoria;
  final int maximo; // por periodo

  const Tope({required this.categoria, required this.maximo});
}

enum NivelTope { bien, cerca, pasado }

typedef EstadoTope = ({
  int usado,
  int porcentaje,
  int restante,
  NivelTope nivel,
});

// extra: un gasto que se está escribiendo y todavía no se registra
EstadoTope estadoTope({
  required Tope tope,
  required List<Gasto> gastos,
  required DateTime inicio,
  required DateTime fin,
  int extra = 0,
}) {
  var usado = extra;
  for (final g in gastos) {
    final fecha = soloFecha(g.fecha);
    if (g.descripcion == tope.categoria &&
        !fecha.isBefore(inicio) &&
        fecha.isBefore(fin)) {
      usado += g.monto;
    }
  }
  final porcentaje = tope.maximo <= 0 ? 100 : usado * 100 ~/ tope.maximo;
  return (
    usado: usado,
    porcentaje: porcentaje,
    restante: tope.maximo - usado,
    nivel: usado > tope.maximo
        ? NivelTope.pasado
        : porcentaje >= 80
        ? NivelTope.cerca
        : NivelTope.bien,
  );
}
