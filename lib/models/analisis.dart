import 'calendario_pagos.dart';
import 'gasto.dart';

typedef Parte = ({String nombre, int monto, int porcentaje});
typedef DiaGastado = ({DateTime dia, int monto});

class Analisis {
  final int total;
  final List<Parte> porCategoria;
  final List<Parte> porMedio;
  final List<DiaGastado> porDia;

  const Analisis({
    required this.total,
    required this.porCategoria,
    required this.porMedio,
    required this.porDia,
  });
}

List<Parte> _partes(Map<String, int> montos, int total) {
  final partes = [
    for (final MapEntry(key: nombre, value: monto) in montos.entries)
      (
        nombre: nombre,
        monto: monto,
        porcentaje: total == 0 ? 0 : monto * 100 ~/ total,
      ),
  ];
  return partes..sort((a, b) => b.monto.compareTo(a.monto));
}

// Lo gastado en el periodo [inicio, fin) hasta hoy (sin programados futuros)
Analisis analizar({
  required List<Gasto> gastos,
  required DateTime inicio,
  required DateTime fin,
  required DateTime hoy,
}) {
  final dia = soloFecha(hoy);
  final hasta = dia.isBefore(fin)
      ? dia
      : DateTime(fin.year, fin.month, fin.day - 1);

  final categorias = <String, int>{};
  final medios = <String, int>{};
  final dias = <DateTime, int>{};
  var total = 0;

  for (final g in gastos) {
    final fecha = soloFecha(g.fecha);
    if (fecha.isBefore(inicio) || fecha.isAfter(hasta)) continue;
    total += g.monto;
    categorias.update(
      g.descripcion,
      (m) => m + g.monto,
      ifAbsent: () => g.monto,
    );
    medios.update(
      g.medioPago.nombre,
      (m) => m + g.monto,
      ifAbsent: () => g.monto,
    );
    dias.update(fecha, (m) => m + g.monto, ifAbsent: () => g.monto);
  }

  return Analisis(
    total: total,
    porCategoria: _partes(categorias, total),
    porMedio: _partes(medios, total),
    porDia: [
      for (
        var d = inicio;
        !d.isAfter(hasta);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        (dia: d, monto: dias[d] ?? 0),
    ],
  );
}
