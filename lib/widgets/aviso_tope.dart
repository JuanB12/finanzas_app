import 'package:flutter/material.dart';

import '../models/metas.dart';
import '../tema.dart';
import '../utils/formato.dart';

Color colorDeNivel(BuildContext context, NivelTope nivel) => switch (nivel) {
  NivelTope.bien => context.c.acento,
  NivelTope.cerca => context.c.textoProgramado,
  NivelTope.pasado => context.c.textoPeligro,
};

// "Llevas $64.000 de $80.000 en Domicilios", mientras escribes el gasto
class AvisoTope extends StatelessWidget {
  const AvisoTope({super.key, required this.tope, required this.estado});

  final Tope tope;
  final EstadoTope estado;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    final color = colorDeNivel(context, e.nivel);
    final mensaje = switch (e.nivel) {
      NivelTope.bien =>
        'Llevas ${formatoPesos(e.usado)} de ${formatoPesos(tope.maximo)} en ${tope.categoria}',
      NivelTope.cerca =>
        'Ojo: llevas ${formatoPesos(e.usado)} de ${formatoPesos(tope.maximo)} en ${tope.categoria}',
      NivelTope.pasado =>
        'Te pasas de tu tope de ${tope.categoria} por ${formatoPesos(-e.restante)}',
    };

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            e.nivel == NivelTope.bien
                ? Icons.speed_rounded
                : Icons.warning_amber_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
