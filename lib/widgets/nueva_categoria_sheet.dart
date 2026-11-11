import 'package:flutter/material.dart';

import '../tema.dart';
import 'categorias.dart';

Future<Categoria?> pedirNuevaCategoria(BuildContext context) {
  return showModalBottomSheet<Categoria>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _NuevaCategoriaSheet(),
  );
}

class _NuevaCategoriaSheet extends StatefulWidget {
  const _NuevaCategoriaSheet();

  @override
  State<_NuevaCategoriaSheet> createState() => _NuevaCategoriaSheetState();
}

class _NuevaCategoriaSheetState extends State<_NuevaCategoriaSheet> {
  final _nombre = TextEditingController();
  IconData _icono = iconosParaOtros.first;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _nombre.text.trim();

    return Padding(
      // Que el teclado no tape la hoja
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Otro gasto',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nombre,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 24,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej. Remedio del perro',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          const Text('Ícono', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final icono in iconosParaOtros)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _icono = icono),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: icono == _icono
                          ? context.c.primario
                          : context.c.superficie,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.c.pista),
                    ),
                    child: Icon(
                      icono,
                      color: icono == _icono
                          ? context.c.acentoSobrePrimario
                          : context.c.texto,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: nombre.isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      Categoria(nombre, 'Personalizada', _icono),
                    ),
              style: FilledButton.styleFrom(
                backgroundColor: context.c.primario,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Listo'),
            ),
          ),
        ],
      ),
    );
  }
}
