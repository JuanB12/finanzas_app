import 'calendario_pagos.dart';
import 'gasto.dart';

String _normalizar(String texto) {
  const tildes = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  return texto
      .toLowerCase()
      .split('')
      .map((letra) => tildes[letra] ?? letra)
      .join();
}

List<Gasto> filtrarGastos(
  List<Gasto> gastos, {
  String texto = '',
  String? categoria,
  MedioPago? medio,
}) {
  final buscado = _normalizar(texto.trim());
  return [
    for (final g in gastos)
      if (_normalizar(g.descripcion).contains(buscado) &&
          (categoria == null || g.descripcion == categoria) &&
          (medio == null || g.medioPago == medio))
        g,
  ];
}

typedef GrupoDia = ({DateTime dia, int total, List<Gasto> gastos});

// Del día más reciente al más viejo; dentro del día, el último registrado primero
List<GrupoDia> agruparPorDia(List<Gasto> gastos) {
  final porDia = <DateTime, List<Gasto>>{};
  for (final g in gastos.reversed) {
    porDia.putIfAbsent(soloFecha(g.fecha), () => []).add(g);
  }
  final dias = porDia.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final dia in dias)
      (
        dia: dia,
        total: porDia[dia]!.fold(0, (suma, g) => suma + g.monto),
        gastos: porDia[dia]!,
      ),
  ];
}
