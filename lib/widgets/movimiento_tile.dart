import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../models/gasto.dart';
import '../models/presupuesto.dart';
import '../tema.dart';
import '../utils/formato.dart';
import 'acciones_gasto.dart';
import 'categorias.dart';

// Un gasto en una lista: tocar para editar, deslizar a la izquierda para borrar
class MovimientoTile extends StatelessWidget {
  const MovimientoTile({super.key, required this.gasto, this.conFecha = true});

  final Gasto gasto;
  final bool conFecha;

  String _etiqueta(ResumenDelDia resumen) {
    final g = gasto;
    final cual = switch (resumen.cualQuincena(g.fecha)) {
      CualQuincena.pasada => 'Quincena pasada',
      CualQuincena.proxima => 'Próxima quincena',
      CualQuincena.actual when g.imprevisto => 'Imprevisto',
      CualQuincena.actual when g.programado => 'Programado',
      CualQuincena.actual when g.deQuincena => 'De la quincena',
      CualQuincena.actual => null,
    };
    return [?cual, g.medioPago.nombre].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);
    final g = gasto;

    return Dismissible(
      key: ObjectKey(g),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => borrarConDeshacer(context, g),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: ListTile(
        onTap: () => abrirRegistro(context, editar: g),
        leading: CircleAvatar(
          backgroundColor: context.c.suave,
          child: Icon(
            iconoDe(g.descripcion, finanzas.categoriasPropias),
            color: context.c.texto,
          ),
        ),
        title: Text(
          g.descripcion,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _etiqueta(finanzas.resumen),
          maxLines: 2, // "De la quincena · Daviplata" no cabe en una línea
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-${formatoPesos(g.monto)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (conFecha)
              Text(
                fechaCorta(g.fecha),
                style: TextStyle(fontSize: 12, color: context.c.textoTenue),
              ),
          ],
        ),
      ),
    );
  }
}
