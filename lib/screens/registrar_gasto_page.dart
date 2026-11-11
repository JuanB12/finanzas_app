import 'package:flutter/material.dart';

import '../models/calendario_pagos.dart';
import '../models/festivos_colombia.dart';
import '../models/gasto.dart';
import '../models/metas.dart';
import '../models/presupuesto.dart';
import '../models/quincena.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../utils/teclado.dart';
import '../widgets/aviso_tope.dart';
import '../widgets/categorias.dart';
import '../widgets/nueva_categoria_sheet.dart';

class RegistrarGastoPage extends StatefulWidget {
  const RegistrarGastoPage({
    super.key,
    required this.gastos,
    required this.quincena,
    this.ahora = DateTime.now,
    required this.categoriasPropias,
    required this.onNuevaCategoria,
    this.inicial,
  });

  final List<Gasto> gastos;
  final Quincena quincena;
  final DateTime Function() ahora;
  final List<Categoria> categoriasPropias;
  final ValueChanged<Categoria> onNuevaCategoria;
  final Gasto? inicial; // si viene, estamos editando

  @override
  State<RegistrarGastoPage> createState() => _RegistrarGastoPageState();
}

class _RegistrarGastoPageState extends State<RegistrarGastoPage> {
  int _monto = 0;
  Categoria _categoria = categorias.first;
  MedioPago _medio = MedioPago.nequi;
  late DateTime _fecha = widget.ahora();
  bool _deQuincena = categorias.first.deQuincena;
  bool _imprevisto = false;
  late final List<Categoria> _propias = [...widget.categoriasPropias];

  bool get _editando => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    final g = widget.inicial;
    if (g == null) return;

    final todas = [...categorias, ..._propias];
    _categoria =
        todas.where((c) => c.nombre == g.descripcion).firstOrNull ??
        Categoria(g.descripcion, 'Personalizada', Icons.receipt_long_rounded);
    _monto = g.monto;
    _medio = g.medioPago;
    _fecha = g.fecha;
    _deQuincena = g.deQuincena;
    _imprevisto = g.imprevisto;
  }

  Tope? get _tope => widget.quincena.topes
      .where((t) => t.categoria == _categoria.nombre)
      .firstOrNull;

  bool get _esProgramado =>
      soloFecha(_fecha).isAfter(soloFecha(widget.ahora()));

  Gasto get _gasto => Gasto(
    descripcion: _categoria.nombre,
    monto: _monto,
    fecha: _fecha,
    programado: _esProgramado,
    deQuincena: _deQuincena && !_imprevisto,
    imprevisto: _imprevisto,
    medioPago: _medio,
  );

  // Cómo quedaría la quincena si confirmas este gasto
  ResumenDelDia get _despues {
    final hoy = widget.ahora();
    return resumenDelDia(
      quincena: widget.quincena,
      gastos: [...widget.gastos, _gasto],
      hoy: hoy,
      festivos: festivosColombiaAlrededorDe(hoy),
    );
  }

  // Lo que queda en el fondo sin contar el gasto que estás escribiendo
  int get _fondoRestante {
    final hoy = widget.ahora();
    return resumenDelDia(
      quincena: widget.quincena,
      gastos: widget.gastos,
      hoy: hoy,
      festivos: festivosColombiaAlrededorDe(hoy),
    ).imprevistosRestantes;
  }

  void _elegirCategoria(Categoria c) {
    setState(() {
      _categoria = c;
      _deQuincena = c.deQuincena;
    });
  }

  Future<void> _crearCategoria() async {
    final nueva = await pedirNuevaCategoria(context);
    if (nueva == null) return;

    final todas = [...categorias, ..._propias];
    final existente = todas.where((c) => c.nombre == nueva.nombre).firstOrNull;
    if (existente == null) {
      widget.onNuevaCategoria(nueva);
      _propias.add(nueva);
    }
    _elegirCategoria(existente ?? nueva);
  }

  Future<void> _elegirFecha() async {
    final hoy = widget.ahora();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: _fecha.isBefore(hoy.subtract(const Duration(days: 60)))
          ? _fecha
          : hoy.subtract(const Duration(days: 60)),
      lastDate: hoy.add(const Duration(days: 60)),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  @override
  Widget build(BuildContext context) {
    final despues = _despues;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _BarraSuperior(
              titulo: _editando ? 'Editar gasto' : 'Registrar gasto',
              fecha: _fecha,
              hoy: widget.ahora(),
              programado: _esProgramado,
              onElegirFecha: _elegirFecha,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Vista(resumen: despues),
                  const SizedBox(height: 20),
                  _Monto(monto: _monto),
                  const SizedBox(height: 20),
                  const _Titulo('Categoría'),
                  _Categorias(
                    todas: [...categorias, ..._propias],
                    elegida: _categoria,
                    onElegir: _elegirCategoria,
                    onOtro: _crearCategoria,
                  ),
                  if (_tope case final tope?)
                    AvisoTope(
                      tope: tope,
                      estado: estadoTope(
                        tope: tope,
                        gastos: widget.gastos,
                        inicio: despues.inicio,
                        fin: despues.fin,
                        extra:
                            despues.cualQuincena(_fecha) == CualQuincena.actual
                            ? _monto
                            : 0,
                      ),
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _imprevisto,
                    onChanged: (v) => setState(() => _imprevisto = v),
                    secondary: Icon(
                      Icons.health_and_safety_outlined,
                      color: context.c.acento,
                    ),
                    title: const Text(
                      'Es un imprevisto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Sale del fondo: te quedan ${formatoPesos(_fondoRestante)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (!_esProgramado && !_imprevisto)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _deQuincena,
                      onChanged: (v) => setState(() => _deQuincena = v),
                      secondary: Icon(
                        Icons.date_range_outlined,
                        color: context.c.acento,
                      ),
                      title: Text(
                        '¿Es para ${widget.quincena.formaDePago.todoElPeriodo}?',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'No se descuenta solo de hoy',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const _Titulo('Medio de pago'),
                  _Medios(
                    elegido: _medio,
                    onElegir: (m) => setState(() => _medio = m),
                  ),
                  const SizedBox(height: 16),
                  _Teclado(
                    onTecla: (t) => setState(() => _monto = teclear(_monto, t)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: _BotonConfirmar(
                texto: _editando ? 'Guardar cambios ' : 'Confirmar gasto ',
                monto: _monto,
                onConfirmar: () => Navigator.pop(context, _gasto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  const _BarraSuperior({
    required this.titulo,
    required this.fecha,
    required this.hoy,
    required this.programado,
    required this.onElegirFecha,
  });

  final String titulo;
  final DateTime fecha;
  final DateTime hoy;
  final bool programado;
  final VoidCallback onElegirFecha;

  @override
  Widget build(BuildContext context) {
    final esHoy = soloFecha(fecha) == soloFecha(hoy);
    final subtitulo = esHoy
        ? 'Hoy · ${fechaCorta(fecha)}'
        : programado
        ? 'Programado · ${fechaCorta(fecha)}'
        : fechaCorta(fecha);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: programado
                        ? context.c.textoProgramado
                        : context.c.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onElegirFecha,
            icon: const Icon(Icons.calendar_today_rounded),
          ),
        ],
      ),
    );
  }
}

class _Vista extends StatelessWidget {
  const _Vista({required this.resumen});

  final ResumenDelDia resumen;

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    final enMeta = r.quedaHoy >= 0 && r.disponibleRestante >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.c.superficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: context.c.acento),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Libre en la quincena después de este gasto',
                  style: TextStyle(fontSize: 12, color: context.c.textoSuave),
                ),
                Text(
                  formatoPesos(r.disponibleRestante),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: r.disponibleRestante < 0
                        ? context.c.textoPeligro
                        : context.c.acento,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: enMeta ? context.c.exito : context.c.peligro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              enMeta ? 'En meta' : 'Te pasas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enMeta ? context.c.acento : context.c.textoPeligro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Monto extends StatelessWidget {
  const _Monto({required this.monto});

  final int monto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Monto del gasto', style: TextStyle(color: context.c.textoSuave)),
        FittedBox(
          child: Text(
            formatoPesos(monto),
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
        ),
        Text(
          'Pesos colombianos (COP)',
          style: TextStyle(fontSize: 12, color: context.c.textoTenue),
        ),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Categorias extends StatelessWidget {
  const _Categorias({
    required this.todas,
    required this.elegida,
    required this.onElegir,
    required this.onOtro,
  });

  final List<Categoria> todas;
  final Categoria elegida;
  final ValueChanged<Categoria> onElegir;
  final VoidCallback onOtro;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.1,
      children: [
        for (final c in todas)
          _Opcion(
            activa: c == elegida,
            onTap: () => onElegir(c),
            child: Row(
              children: [
                Icon(c.icono, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        c.detalle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        _Opcion(
          activa: false,
          onTap: onOtro,
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 20),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Otro',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Medios extends StatelessWidget {
  const _Medios({required this.elegido, required this.onElegir});

  final MedioPago elegido;
  final ValueChanged<MedioPago> onElegir;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in MedioPago.values) ...[
          Expanded(
            child: SizedBox(
              height: 42,
              child: _Opcion(
                activa: m == elegido,
                onTap: () => onElegir(m),
                child: Center(
                  child: Text(
                    m.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          if (m != MedioPago.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

// Una tarjetica que se pone negra cuando está elegida
class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.activa,
    required this.onTap,
    required this.child,
  });

  final bool activa;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activa ? context.c.primario : context.c.superficie,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconTheme(
            data: IconThemeData(
              color: activa ? context.c.acentoSobrePrimario : context.c.acento,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: activa ? context.c.sobrePrimario : context.c.texto,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Teclado extends StatelessWidget {
  const _Teclado({required this.onTecla});

  final ValueChanged<String> onTecla;

  static const _teclas = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '000',
    '0',
    borrar,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: [
        for (final t in _teclas)
          Material(
            key: ValueKey('tecla-$t'),
            color: t == '000' || t == borrar
                ? context.c.suave
                : context.c.superficie,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTecla(t),
              child: Center(
                child: t == borrar
                    ? const Icon(Icons.backspace_outlined)
                    : Text(
                        t == '000' ? '+000' : t,
                        style: TextStyle(
                          fontSize: t == '000' ? 16 : 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BotonConfirmar extends StatelessWidget {
  const _BotonConfirmar({
    required this.texto,
    required this.monto,
    required this.onConfirmar,
  });

  final String texto;
  final int monto;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: monto > 0 ? onConfirmar : null,
        style: FilledButton.styleFrom(
          backgroundColor: context.c.primario,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text.rich(
          TextSpan(
            text: texto,
            children: [
              TextSpan(
                text: '(${formatoPesos(monto)})',
                style: TextStyle(color: context.c.acentoSobrePrimario),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
