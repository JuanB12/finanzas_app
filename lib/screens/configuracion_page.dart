import 'package:flutter/material.dart';

import '../models/festivos_colombia.dart';
import '../models/forma_de_pago.dart';
import '../models/presupuesto.dart';
import '../models/quincena.dart';
import '../tema.dart';
import '../utils/formato.dart';

typedef Configuracion = ({String nombre, Quincena quincena});

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({
    super.key,
    required this.inicial,
    this.ahora = DateTime.now,
  });

  final Configuracion inicial;
  final DateTime Function() ahora;

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  late final _nombre = TextEditingController(text: widget.inicial.nombre);
  late final _ingresos = TextEditingController(
    text: formatoMiles(widget.inicial.quincena.ingresos),
  );
  late Frecuencia _frecuencia = widget.inicial.quincena.formaDePago.frecuencia;
  late int _primerDia = widget.inicial.quincena.formaDePago.primerDia;
  late int _segundoDia =
      widget.inicial.quincena.formaDePago.segundoDia ?? ultimoDia;
  late int _ahorro = widget.inicial.quincena.porcentajeAhorro;
  late int _imprevistos = widget.inicial.quincena.porcentajeImprevistos;
  late final List<GastoFijo> _fijos = [...widget.inicial.quincena.gastosFijos];

  @override
  void dispose() {
    _nombre.dispose();
    _ingresos.dispose();
    super.dispose();
  }

  bool get _quincenal => _frecuencia == Frecuencia.quincenal;

  Quincena get _quincena => Quincena(
    ingresos: leerMonto(_ingresos.text),
    gastosFijos: _fijos,
    porcentajeAhorro: _ahorro,
    porcentajeImprevistos: _imprevistos,
    formaDePago: _quincenal
        ? FormaDePago.quincenal(primerDia: _primerDia, segundoDia: _segundoDia)
        : FormaDePago.mensual(dia: _primerDia),
  );

  // Una "huella" de la configuración para saber si algo cambió
  String _huella(String nombre, Quincena q) => [
    nombre,
    q.ingresos,
    q.formaDePago.frecuencia,
    q.formaDePago.primerDia,
    q.formaDePago.segundoDia,
    q.porcentajeAhorro,
    q.porcentajeImprevistos,
    for (final f in q.gastosFijos) '${f.nombre}:${f.monto}:${f.diaCobro}',
  ].join('|');

  bool get _hayCambios =>
      _huella(_nombre.text.trim(), _quincena) !=
      _huella(widget.inicial.nombre, widget.inicial.quincena);

  Future<void> _confirmarSalida() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar los cambios?'),
        content: const Text('Si sales ahora, se pierde lo que cambiaste.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (descartar == true && mounted) Navigator.pop(context);
  }

  String? get _error {
    if (_nombre.text.trim().isEmpty) return 'Escribe tu nombre';
    if ((leerMonto(_ingresos.text)) <= 0) return 'Escribe tu ingreso';
    if (_quincenal && _primerDia >= _segundoDia) {
      return 'El primer día de pago debe ir antes que el segundo';
    }
    return null;
  }

  Future<void> _editarFijo([GastoFijo? actual]) async {
    final fijo = await showDialog<GastoFijo>(
      context: context,
      builder: (_) => _GastoFijoDialog(inicial: actual, periodo: _periodo),
    );
    if (fijo == null) return;
    setState(() {
      if (actual == null) {
        _fijos.add(fijo);
      } else {
        _fijos[_fijos.indexOf(actual)] = fijo;
      }
    });
  }

  String get _periodo => _quincenal ? 'quincena' : 'mes';

  @override
  Widget build(BuildContext context) {
    final q = _quincena;
    final error = _error;

    return PopScope(
      canPop: !_hayCambios,
      onPopInvokedWithResult: (salio, _) {
        if (!salio) _confirmarSalida();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tu configuración')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const _Seccion('¿Cómo te pagan?'),
            SegmentedButton<Frecuencia>(
              segments: const [
                ButtonSegment(
                  value: Frecuencia.quincenal,
                  label: Text('Quincenal'),
                ),
                ButtonSegment(
                  value: Frecuencia.mensual,
                  label: Text('Mensual'),
                ),
              ],
              selected: {_frecuencia},
              onSelectionChanged: (s) => setState(() {
                _frecuencia = s.first;
                // Valores típicos al cambiar
                _primerDia = _quincenal ? 15 : ultimoDia;
                _segundoDia = ultimoDia;
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ingresos,
              keyboardType: TextInputType.number,
              inputFormatters: const [MilesFormatter()],
              decoration: InputDecoration(
                labelText: _quincenal
                    ? 'Ingreso por quincena'
                    : 'Ingreso mensual',
                prefixText: r'$ ',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const _Seccion('Días de pago'),
            Row(
              children: [
                Expanded(
                  child: _SelectorDia(
                    etiqueta: _quincenal ? 'Primer pago' : 'Día de pago',
                    valor: _primerDia,
                    onCambio: (d) => setState(() => _primerDia = d),
                  ),
                ),
                if (_quincenal) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectorDia(
                      etiqueta: 'Segundo pago',
                      valor: _segundoDia,
                      onCambio: (d) => setState(() => _segundoDia = d),
                    ),
                  ),
                ],
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Si cae fin de semana o festivo, la app cuenta el día hábil anterior.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const _Seccion('Lo que separas apenas te pagan'),
            _Porcentaje(
              icono: Icons.savings_outlined,
              titulo: 'Ahorro',
              valor: _ahorro,
              maximo: 50,
              monto: q.ahorro,
              onCambio: (v) => setState(() => _ahorro = v),
            ),
            _Porcentaje(
              icono: Icons.health_and_safety_outlined,
              titulo: 'Imprevistos',
              valor: _imprevistos,
              maximo: 20,
              monto: q.fondoImprevistos,
              onCambio: (v) => setState(() => _imprevistos = v),
            ),
            const _Seccion('Gastos fijos'),
            const Text(
              'Toca uno para editarlo',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            for (final f in _fijos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _editarFijo(f),
                title: Text(f.nombre),
                subtitle: Text(
                  '${formatoPesos(f.monto)} · ${f.diaCobro == null ? 'cada $_periodo' : 'se cobra el ${_textoDia(f.diaCobro!)}'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => setState(() => _fijos.remove(f)),
                ),
              ),
            TextButton.icon(
              onPressed: _editarFijo,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar gasto fijo'),
            ),
            const SizedBox(height: 16),
            _Resumen(quincena: q, hoy: widget.ahora()),
            const SizedBox(height: 16),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              onPressed: error != null
                  ? null
                  : () => Navigator.pop<Configuracion>(context, (
                      nombre: _nombre.text.trim(),
                      quincena: q,
                    )),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SelectorDia extends StatelessWidget {
  const _SelectorDia({
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

class _Porcentaje extends StatelessWidget {
  const _Porcentaje({
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
            Icon(icono, size: 20, color: verde),
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
        Slider(
          value: valor.toDouble(),
          max: maximo.toDouble(),
          divisions: maximo,
          activeColor: verde,
          onChanged: (v) => onCambio(v.round()),
        ),
      ],
    );
  }
}

String _textoDia(int dia) => dia == ultimoDia ? 'último día' : 'día $dia';

class _Resumen extends StatelessWidget {
  const _Resumen({required this.quincena, required this.hoy});

  final Quincena quincena;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final periodos = proximosPeriodos(
      quincena: quincena,
      hoy: hoy,
      festivos: festivosColombiaAlrededorDe(hoy),
    );
    final nombre = quincena.formaDePago.nombrePeriodo.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: azulOscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Te quedan para gastar',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          for (final (i, p) in periodos.indexed) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i == 0 ? 'Esta' : 'Próxima'} $nombre · ${fechaCorta(p.inicio)} al ${fechaCorta(p.fin.subtract(const Duration(days: 1)))}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Fijos: ${formatoPesos(p.fijos)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatoPesos(p.disponible),
                  style: TextStyle(
                    color: p.disponible < 0 ? rojoSuave : verdeClaro,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
          if (periodos.any((p) => p.disponible < 0))
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'En rojo: tus fijos y lo que separas superan tu ingreso',
                style: TextStyle(color: rojoSuave, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _GastoFijoDialog extends StatefulWidget {
  const _GastoFijoDialog({required this.inicial, required this.periodo});

  final GastoFijo? inicial;
  final String periodo;

  @override
  State<_GastoFijoDialog> createState() => _GastoFijoDialogState();
}

class _GastoFijoDialogState extends State<_GastoFijoDialog> {
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
              _SelectorDia(
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
