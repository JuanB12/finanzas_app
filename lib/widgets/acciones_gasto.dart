import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../models/gasto.dart';
import '../screens/registrar_gasto_page.dart';

Future<void> abrirRegistro(BuildContext context, {Gasto? editar}) async {
  final finanzas = FinanzasScope.de(context);
  final gasto = await Navigator.push<Gasto>(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => RegistrarGastoPage(
        // Al editar, la vista previa no debe contar el gasto dos veces
        gastos: [
          for (final g in finanzas.gastos)
            if (!identical(g, editar)) g,
        ],
        quincena: finanzas.quincena,
        ahora: finanzas.ahora,
        categoriasPropias: finanzas.categoriasPropias,
        onNuevaCategoria: finanzas.agregarCategoria,
        inicial: editar,
      ),
    ),
  );
  if (gasto == null) return;
  if (editar == null) {
    finanzas.agregarGasto(gasto);
  } else {
    finanzas.reemplazarGasto(editar, gasto);
  }
}

void borrarConDeshacer(BuildContext context, Gasto gasto) {
  final finanzas = FinanzasScope.de(context);
  final posicion = finanzas.borrarGasto(gasto);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Borraste ${gasto.descripcion}'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => finanzas.insertarGasto(posicion, gasto),
        ),
      ),
    );
}
