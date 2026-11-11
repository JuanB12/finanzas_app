import 'package:flutter/material.dart';

import '../models/forma_de_pago.dart';
import '../models/quincena.dart';
import '../tema.dart';
import '../utils/formato.dart';

// Piezas del plan que usan Mi plan y la bienvenida

class SelectorDia extends StatelessWidget {
  const SelectorDia({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.onCambio,
  });

  final String etiqueta;
  final int valor;
  final ValueChanged<int> onCambio;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      // La key hace que se redibuje si el valor cambia desde afuera
      key: ValueKey('$etiqueta-$valor'),
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (var d = 1; d <= ultimoDia; d++)
          DropdownMenuItem(
            value: d,
            child: Text(d == ultimoDia ? 'Último día' : 'Día $d'),
          ),
      ],
      onChanged: (d) {
        if (d != null) onCambio(d);
      },
    );
  }
}

class Porcentaje extends StatelessWidget {
  const Porcentaje({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.maximo,
    required this.monto,
    required this.onCambio,
  });

  final IconData icono;
  final String titulo;
  final int valor;
  final int maximo;
  final int monto;
  final ValueChanged<int> onCambio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 20, color: context.c.acento),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text('$valor% · ${formatoPesos(monto)}'),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context)
              .copyWith(tickMarkShape: SliderTickMarkShape.noTickMark),
          child: Slider(
            value: valor.toDouble(),
            max: maximo.toDouble(),
            divisions: maximo,
            activeColor: context.c.acento,
            onChanged: (v) => onCambio(v.round()),
          ),
        ),
      ],
    );
  }
}

String textoDia(int dia) => dia == ultimoDia ? 'último día' : 'día $dia';

class GastoFijoDialog extends StatefulWidget {
  const GastoFijoDialog({
    super.key,
    required this.inicial,
    required this.periodo,
  });

  final GastoFijo? inicial;
  final String periodo;

  @override
  State<GastoFijoDialog> createState() => GastoFijoDialogState();
}

class GastoFijoDialogState extends State<GastoFijoDialog> {
  late final _nombre = TextEditingController(text: widget.inicial?.nombre);
  late final _monto = TextEditingController(
    text: widget.inicial == null ? null : formatoMiles(widget.inicial!.monto),
  );
  late bool _mensual =
      widget.inicial == null || widget.inicial!.diaCobro != null;
  late int _dia = widget.inicial?.diaCobro ?? 1;

  @override
  void dispose() {
    _nombre.dispose();
    _monto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monto = leerMonto(_monto.text);
    final listo = _nombre.text.trim().isNotEmpty && monto > 0;

    return AlertDialog(
      title: Text(
        widget.inicial == null ? 'Nuevo gasto fijo' : 'Editar gasto fijo',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombre,
              autofocus: widget.inicial == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _monto,
              keyboardType: TextInputType.number,
              inputFormatters: const [MilesFormatter()],
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixText: r'$ ',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cada cuánto se paga?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                const ButtonSegment(value: true, label: Text('Cada mes')),
                ButtonSegment(
                  value: false,
                  label: Text('Cada ${widget.periodo}'),
                ),
              ],
              selected: {_mensual},
              onSelectionChanged: (s) => setState(() => _mensual = s.first),
            ),
            if (_mensual) ...[
              const SizedBox(height: 16),
              SelectorDia(
                etiqueta: '¿Qué día te lo cobran?',
                valor: _dia,
                onCambio: (d) => setState(() => _dia = d),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: listo
              ? () => Navigator.pop(
                  context,
                  GastoFijo(
                    nombre: _nombre.text.trim(),
                    monto: monto,
                    diaCobro: _mensual ? _dia : null,
                  ),
                )
              : null,
          child: Text(widget.inicial == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}
