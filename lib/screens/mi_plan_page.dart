import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../models/colchon.dart';
import '../models/festivos_colombia.dart';
import '../models/forma_de_pago.dart';
import '../models/metas.dart';
import '../models/presupuesto.dart';
import '../models/quincena.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../widgets/aviso_tope.dart';
import '../widgets/campos_plan.dart';
import '../widgets/categorias.dart';

class MiPlanPage extends StatefulWidget {
  const MiPlanPage({
    super.key,
    required this.inicial,
    required this.onGuardar,
    this.ahora = DateTime.now,
  });

  final Quincena inicial;
  final ValueChanged<Quincena> onGuardar;
  final DateTime Function() ahora;

  @override
  State<MiPlanPage> createState() => _MiPlanPageState();
}

class _MiPlanPageState extends State<MiPlanPage> {
  final _ingresos = TextEditingController();
  late Frecuencia _frecuencia;
  late int _primerDia;
  late int _segundoDia;
  late int _ahorro;
  late int _imprevistos;
  late List<GastoFijo> _fijos;
  late List<Meta> _metas;
  late List<Tope> _topes;

  @override
  void initState() {
    super.initState();
    _cargar(widget.inicial);
  }

  // Si la configuración guardada cambia y aquí no hay nada pendiente, se recarga
  @override
  void didUpdateWidget(MiPlanPage viejo) {
    super.didUpdateWidget(viejo);
    if (!_cambioRespectoA(viejo.inicial)) _cargar(widget.inicial);
  }

  void _cargar(Quincena q) {
    _ingresos.text = formatoMiles(q.ingresos);
    _frecuencia = q.formaDePago.frecuencia;
    _primerDia = q.formaDePago.primerDia;
    _segundoDia = q.formaDePago.segundoDia ?? ultimoDia;
    _ahorro = q.porcentajeAhorro;
    _imprevistos = q.porcentajeImprevistos;
    _fijos = [...q.gastosFijos];
    _metas = [...q.metas];
    _topes = [...q.topes];
  }

  @override
  void dispose() {
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
    metas: _metas,
    topes: _topes,
  );

  // Una "huella" de la configuración para saber si algo cambió
  String _huella(Quincena q) => [
    q.ingresos,
    q.formaDePago.frecuencia,
    q.formaDePago.primerDia,
    q.formaDePago.segundoDia,
    q.porcentajeAhorro,
    q.porcentajeImprevistos,
    for (final f in q.gastosFijos) '${f.nombre}:${f.monto}:${f.diaCobro}',
    for (final m in q.metas)
      'm:${m.nombre}:${m.objetivo}:${m.ahorrado}:${m.aporte}',
    for (final t in q.topes) 't:${t.categoria}:${t.maximo}',
  ].join('|');

  bool _cambioRespectoA(Quincena q) => _huella(_quincena) != _huella(q);

  bool get _hayCambios => _cambioRespectoA(widget.inicial);

  void _guardar() {
    widget.onGuardar(_quincena);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Guardado ✓')));
  }

  void _descartar() => setState(() => _cargar(widget.inicial));

  String? get _error {
    if ((leerMonto(_ingresos.text)) <= 0) return 'Escribe tu ingreso';
    if (_quincenal && _primerDia >= _segundoDia) {
      return 'El primer día de pago debe ir antes que el segundo';
    }
    return null;
  }

  Future<void> _editarFijo([GastoFijo? actual]) async {
    final fijo = await showDialog<GastoFijo>(
      context: context,
      builder: (_) => GastoFijoDialog(inicial: actual, periodo: _periodo),
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

  // Reemplaza `actual` por `nuevo` en la lista, o lo agrega si es nuevo
  void _poner<T>(List<T> lista, T? actual, T nuevo) => setState(() {
    if (actual == null) {
      lista.add(nuevo);
    } else {
      lista[lista.indexOf(actual)] = nuevo;
    }
  });

  Future<void> _editarMeta([Meta? actual]) async {
    final meta = await showDialog<Meta>(
      context: context,
      builder: (_) => _MetaDialog(inicial: actual, periodo: _periodo),
    );
    if (meta != null) _poner(_metas, actual, meta);
  }

  Future<void> _editarTope([Tope? actual]) async {
    final finanzas = FinanzasScope.de(context);
    final nombres = [
      for (final c in [...categorias, ...finanzas.categoriasPropias]) c.nombre,
    ];
    final tope = await showDialog<Tope>(
      context: context,
      builder: (_) =>
          _TopeDialog(inicial: actual, categorias: nombres, periodo: _periodo),
    );
    if (tope != null) _poner(_topes, actual, tope);
  }

  Future<void> _agregarIngresoExtra() async {
    final finanzas = FinanzasScope.de(context);
    final ingreso = await showDialog<IngresoExtra>(
      context: context,
      builder: (_) => _IngresoExtraDialog(hoy: widget.ahora()),
    );
    if (ingreso != null) finanzas.agregarIngresoExtra(ingreso);
  }

  @override
  Widget build(BuildContext context) {
    final q = _quincena;
    final error = _error;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Mi plan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (_hayCambios)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              decoration: BoxDecoration(
                color: context.c.aviso,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('Tienes cambios sin guardar')),
                  TextButton(
                    onPressed: _descartar,
                    child: const Text('Descartar'),
                  ),
                ],
              ),
            ),
          Text(
            'Cuánto te entra, qué sale fijo y cuánto separas',
            style: TextStyle(color: context.c.textoSuave),
          ),
          const _Seccion('¿Cómo te pagan?'),
          SegmentedButton<Frecuencia>(
            segments: const [
              ButtonSegment(
                value: Frecuencia.quincenal,
                label: Text('Quincenal'),
              ),
              ButtonSegment(value: Frecuencia.mensual, label: Text('Mensual')),
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
                child: SelectorDia(
                  etiqueta: _quincenal ? 'Primer pago' : 'Día de pago',
                  valor: _primerDia,
                  onCambio: (d) => setState(() => _primerDia = d),
                ),
              ),
              if (_quincenal) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SelectorDia(
                    etiqueta: 'Segundo pago',
                    valor: _segundoDia,
                    onCambio: (d) => setState(() => _segundoDia = d),
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Si cae fin de semana o festivo, la app cuenta el día hábil anterior.',
              style: TextStyle(fontSize: 12, color: context.c.textoSuave),
            ),
          ),
          const _Seccion('Lo que separas apenas te pagan'),
          Porcentaje(
            icono: Icons.savings_outlined,
            titulo: 'Ahorro',
            valor: _ahorro,
            maximo: 50,
            monto: q.ahorro,
            onCambio: (v) => setState(() => _ahorro = v),
          ),
          Porcentaje(
            icono: Icons.health_and_safety_outlined,
            titulo: 'Imprevistos',
            valor: _imprevistos,
            maximo: 20,
            monto: q.fondoImprevistos,
            onCambio: (v) => setState(() => _imprevistos = v),
          ),
          const _Seccion('Gastos fijos'),
          Text(
            'Toca uno para editarlo',
            style: TextStyle(fontSize: 12, color: context.c.textoSuave),
          ),
          if (_fijos.isNotEmpty)
            Material(
              color: context.c.superficie,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final f in _fijos)
                    ListTile(
                      onTap: () => _editarFijo(f),
                      title: Text(f.nombre),
                      subtitle: Text(
                        '${formatoPesos(f.monto)} · ${f.diaCobro == null ? 'cada $_periodo' : 'se cobra el ${textoDia(f.diaCobro!)}'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => setState(() => _fijos.remove(f)),
                      ),
                    ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _editarFijo,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar gasto fijo'),
          ),
          const _Seccion('Metas de ahorro'),
          Text(
            'Apartas un aporte fijo cada vez que te pagan, como el ahorro',
            style: TextStyle(fontSize: 12, color: context.c.textoSuave),
          ),
          const SizedBox(height: 8),
          if (_metas.isNotEmpty)
            _Lista(
              children: [
                for (final m in _metas)
                  _MetaTile(
                    meta: m,
                    quincena: q,
                    hoy: widget.ahora(),
                    periodo: _periodo,
                    onTap: () => _editarMeta(m),
                    onBorrar: () => setState(() => _metas.remove(m)),
                  ),
              ],
            ),
          TextButton.icon(
            onPressed: _editarMeta,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar meta'),
          ),
          const _Seccion('Topes por categoría'),
          Text(
            'Un máximo por $_periodo. Te avisamos desde el 80%',
            style: TextStyle(fontSize: 12, color: context.c.textoSuave),
          ),
          const SizedBox(height: 8),
          if (_topes.isNotEmpty)
            _Lista(
              children: [
                for (final t in _topes)
                  _TopeTile(
                    tope: t,
                    onTap: () => _editarTope(t),
                    onBorrar: () => setState(() => _topes.remove(t)),
                  ),
              ],
            ),
          TextButton.icon(
            onPressed: _editarTope,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar tope'),
          ),
          const SizedBox(height: 16),
          _Resumen(quincena: q, hoy: widget.ahora()),
          const SizedBox(height: 16),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                error,
                style: TextStyle(color: context.c.textoPeligro),
              ),
            ),
          FilledButton(
            onPressed: error != null || !_hayCambios ? null : _guardar,
            style: FilledButton.styleFrom(
              backgroundColor: context.c.primario,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Guardar'),
          ),
          const _Seccion('Colchón'),
          _Colchon(onAgregar: _agregarIngresoExtra),
        ],
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
    final forma = quincena.formaDePago;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.tarjeta,
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
                        '${i == 0 ? forma.este : forma.proximo} · ${fechaCorta(p.inicio)} al ${fechaCorta(p.fin.subtract(const Duration(days: 1)))}',
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

class _Lista extends StatelessWidget {
  const _Lista({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.c.superficie,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.valor, required this.color});

  final double valor; // 0 a 1
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: valor.clamp(0, 1),
        minHeight: 8,
        backgroundColor: context.c.pista,
        color: color,
      ),
    );
  }
}

String _fechaConAnio(DateTime fecha, DateTime hoy) =>
    '${fechaCorta(fecha)}${fecha.year != hoy.year ? ' de ${fecha.year}' : ''}';

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.meta,
    required this.quincena,
    required this.hoy,
    required this.periodo,
    required this.onTap,
    required this.onBorrar,
  });

  final Meta meta;
  final Quincena quincena;
  final DateTime hoy;
  final String periodo;
  final VoidCallback onTap;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final m = meta;
    final fecha = fechaEstimada(
      meta: m,
      quincena: quincena,
      hoy: hoy,
      festivos: FinanzasScope.de(context).festivos,
    );
    final cuando = m.cumplida
        ? '¡Meta cumplida!'
        : fecha == null
        ? 'Ponle un aporte para saber cuándo llegas'
        : 'Apartas ${formatoPesos(m.aporte)} cada $periodo · llegas el ${_fechaConAnio(fecha, hoy)}';

    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.flag_outlined, color: context.c.acento),
      title: Text(
        m.nombre,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          _Barra(valor: m.porcentaje / 100, color: context.c.acento),
          const SizedBox(height: 6),
          Text(
            '${formatoPesos(m.ahorrado)} de ${formatoPesos(m.objetivo)} · ${m.porcentaje}%',
          ),
          Text(cuando, style: TextStyle(color: context.c.textoSuave)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: onBorrar,
      ),
    );
  }
}

class _TopeTile extends StatelessWidget {
  const _TopeTile({
    required this.tope,
    required this.onTap,
    required this.onBorrar,
  });

  final Tope tope;
  final VoidCallback onTap;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);
    final r = finanzas.resumen;
    final e = estadoTope(
      tope: tope,
      gastos: finanzas.gastos,
      inicio: r.inicio,
      fin: r.fin,
    );
    final color = colorDeNivel(context, e.nivel);

    return ListTile(
      onTap: onTap,
      leading: Icon(
        iconoDe(tope.categoria, finanzas.categoriasPropias),
        color: context.c.texto,
      ),
      title: Text(
        tope.categoria,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          _Barra(valor: e.usado / tope.maximo, color: color),
          const SizedBox(height: 6),
          Text(
            'Llevas ${formatoPesos(e.usado)} de ${formatoPesos(tope.maximo)}',
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: onBorrar,
      ),
    );
  }
}

class _Colchon extends StatelessWidget {
  const _Colchon({required this.onAgregar});

  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);
    final colchon = finanzas.colchon;
    final hoy = finanzas.ahora();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La prima, las cesantías y la plata extra. No se suma a tu límite diario',
          style: TextStyle(fontSize: 12, color: context.c.textoSuave),
        ),
        const SizedBox(height: 8),
        _Lista(
          children: [
            ListTile(
              leading: Icon(Icons.savings_outlined, color: context.c.acento),
              title: const Text('Total en el colchón'),
              trailing: Text(
                formatoPesos(colchon.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final i in colchon.ingresos.reversed)
              ListTile(
                title: Text(i.nombre),
                subtitle: Text(_fechaConAnio(i.fecha, hoy)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+${formatoPesos(i.monto)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => finanzas.borrarIngresoExtra(i),
                    ),
                  ],
                ),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: onAgregar,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Agregar ingreso extra'),
        ),
      ],
    );
  }
}

class _CampoPlata extends StatelessWidget {
  const _CampoPlata({
    required this.controlador,
    required this.etiqueta,
    required this.onCambio,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final VoidCallback onCambio;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      keyboardType: TextInputType.number,
      inputFormatters: const [MilesFormatter()],
      decoration: InputDecoration(labelText: etiqueta, prefixText: r'$ '),
      onChanged: (_) => onCambio(),
    );
  }
}

String? _plata(int? monto) => monto == null ? null : formatoMiles(monto);

class _MetaDialog extends StatefulWidget {
  const _MetaDialog({required this.inicial, required this.periodo});

  final Meta? inicial;
  final String periodo;

  @override
  State<_MetaDialog> createState() => _MetaDialogState();
}

class _MetaDialogState extends State<_MetaDialog> {
  late final _nombre = TextEditingController(text: widget.inicial?.nombre);
  late final _objetivo = TextEditingController(
    text: _plata(widget.inicial?.objetivo),
  );
  late final _ahorrado = TextEditingController(
    text: _plata(widget.inicial?.ahorrado),
  );
  late final _aporte = TextEditingController(
    text: _plata(widget.inicial?.aporte),
  );

  @override
  void dispose() {
    for (final c in [_nombre, _objetivo, _ahorrado, _aporte]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final objetivo = leerMonto(_objetivo.text);
    final listo = _nombre.text.trim().isNotEmpty && objetivo > 0;
    void cambio() => setState(() {});

    return AlertDialog(
      title: Text(widget.inicial == null ? 'Nueva meta' : 'Editar meta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombre,
              autofocus: widget.inicial == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. Viaje a Cartagena',
              ),
              onChanged: (_) => cambio(),
            ),
            _CampoPlata(
              controlador: _objetivo,
              etiqueta: '¿Cuánto necesitas?',
              onCambio: cambio,
            ),
            _CampoPlata(
              controlador: _ahorrado,
              etiqueta: '¿Cuánto llevas?',
              onCambio: cambio,
            ),
            _CampoPlata(
              controlador: _aporte,
              etiqueta: '¿Cuánto apartas cada ${widget.periodo}?',
              onCambio: cambio,
            ),
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
                  Meta(
                    nombre: _nombre.text.trim(),
                    objetivo: objetivo,
                    ahorrado: leerMonto(_ahorrado.text),
                    aporte: leerMonto(_aporte.text),
                  ),
                )
              : null,
          child: Text(widget.inicial == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}

class _TopeDialog extends StatefulWidget {
  const _TopeDialog({
    required this.inicial,
    required this.categorias,
    required this.periodo,
  });

  final Tope? inicial;
  final List<String> categorias;
  final String periodo;

  @override
  State<_TopeDialog> createState() => _TopeDialogState();
}

class _TopeDialogState extends State<_TopeDialog> {
  late String _categoria = widget.inicial?.categoria ?? widget.categorias.first;
  late final _maximo = TextEditingController(
    text: _plata(widget.inicial?.maximo),
  );

  @override
  void dispose() {
    _maximo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maximo = leerMonto(_maximo.text);

    return AlertDialog(
      title: Text(widget.inicial == null ? 'Nuevo tope' : 'Editar tope'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _categoria,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Categoría'),
            items: [
              for (final c in widget.categorias)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (c) {
              if (c != null) setState(() => _categoria = c);
            },
          ),
          _CampoPlata(
            controlador: _maximo,
            etiqueta: 'Máximo por ${widget.periodo}',
            onCambio: () => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: maximo > 0
              ? () => Navigator.pop(
                  context,
                  Tope(categoria: _categoria, maximo: maximo),
                )
              : null,
          child: Text(widget.inicial == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}

class _IngresoExtraDialog extends StatefulWidget {
  const _IngresoExtraDialog({required this.hoy});

  final DateTime hoy;

  @override
  State<_IngresoExtraDialog> createState() => _IngresoExtraDialogState();
}

class _IngresoExtraDialogState extends State<_IngresoExtraDialog> {
  final _nombre = TextEditingController();
  final _monto = TextEditingController();

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
      title: const Text('Ingreso extra'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombre,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: '¿De dónde salió?',
              hintText: 'Ej. Prima de diciembre',
            ),
            onChanged: (_) => setState(() {}),
          ),
          _CampoPlata(
            controlador: _monto,
            etiqueta: 'Monto',
            onCambio: () => setState(() {}),
          ),
        ],
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
                  IngresoExtra(
                    nombre: _nombre.text.trim(),
                    monto: monto,
                    fecha: widget.hoy,
                  ),
                )
              : null,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
