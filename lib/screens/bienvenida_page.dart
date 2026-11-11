import 'package:flutter/material.dart';

import '../models/festivos_colombia.dart';
import '../models/forma_de_pago.dart';
import '../models/presupuesto.dart';
import '../models/quincena.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../widgets/campos_plan.dart';

// Primer uso: una pregunta por pantalla y, al final, cuánto puedes gastar hoy
class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({
    super.key,
    required this.onTerminar,
    this.ahora = DateTime.now,
  });

  final void Function(String nombre, Quincena plan) onTerminar;
  final DateTime Function() ahora;

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  static const _totalPasos = 5;

  final _paginas = PageController();
  final _nombre = TextEditingController();
  final _ingresos = TextEditingController();
  int _paso = 0;
  Frecuencia _frecuencia = Frecuencia.quincenal;
  int _primerDia = 15;
  int _segundoDia = ultimoDia;
  int _ahorro = 10;
  final List<GastoFijo> _fijos = [];

  @override
  void dispose() {
    _paginas.dispose();
    _nombre.dispose();
    _ingresos.dispose();
    super.dispose();
  }

  bool get _quincenal => _frecuencia == Frecuencia.quincenal;
  String get _periodo => _quincenal ? 'quincena' : 'mes';

  Quincena get _plan => Quincena(
    ingresos: leerMonto(_ingresos.text),
    gastosFijos: _fijos,
    porcentajeAhorro: _ahorro,
    porcentajeImprevistos: 5,
    formaDePago: _quincenal
        ? FormaDePago.quincenal(primerDia: _primerDia, segundoDia: _segundoDia)
        : FormaDePago.mensual(dia: _primerDia),
  );

  bool get _puedeSeguir => switch (_paso) {
    0 => _nombre.text.trim().isNotEmpty,
    1 => !_quincenal || _primerDia < _segundoDia,
    2 => leerMonto(_ingresos.text) > 0,
    _ => true,
  };

  void _ir(int paso) {
    FocusScope.of(context).unfocus();
    setState(() => _paso = paso);
    _paginas.animateToPage(
      paso,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _siguiente() {
    if (_paso == _totalPasos - 1) {
      widget.onTerminar(_nombre.text.trim(), _plan);
    } else {
      _ir(_paso + 1);
    }
  }

  Future<void> _agregarFijo() async {
    final fijo = await showDialog<GastoFijo>(
      context: context,
      builder: (_) => GastoFijoDialog(inicial: null, periodo: _periodo),
    );
    if (fijo != null) setState(() => _fijos.add(fijo));
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _paso == _totalPasos - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Atrás',
                    onPressed: _paso == 0 ? null : () => _ir(_paso - 1),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_paso + 1) / _totalPasos,
                        minHeight: 6,
                        backgroundColor: context.c.pista,
                        color: context.c.acento,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _paginas,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _pasoNombre(),
                  _pasoPago(),
                  _pasoIngreso(),
                  _pasoFijos(),
                  _pasoListo(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _puedeSeguir ? _siguiente : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.c.primario,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                    ultimo ? 'Empezar' : 'Siguiente',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pasoNombre() => _Paso(
    titulo: 'Bienvenido a Mis finanzas',
    subtitulo: 'Te vamos a decir cuánto puedes gastar cada día, sin hojas de cálculo. Son 4 preguntas.',
    children: [
      TextField(
        controller: _nombre,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: '¿Cómo te llamas?',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (_puedeSeguir) _siguiente();
        },
      ),
    ],
  );

  Widget _pasoPago() => _Paso(
    titulo: '¿Cómo te pagan?',
    subtitulo: 'Así sabemos cuántos días tiene que alcanzarte la plata.',
    children: [
      SegmentedButton<Frecuencia>(
        segments: const [
          ButtonSegment(value: Frecuencia.quincenal, label: Text('Quincenal')),
          ButtonSegment(value: Frecuencia.mensual, label: Text('Mensual')),
        ],
        selected: {_frecuencia},
        onSelectionChanged: (s) => setState(() {
          _frecuencia = s.first;
          _primerDia = _quincenal ? 15 : ultimoDia;
          _segundoDia = ultimoDia;
        }),
      ),
      const SizedBox(height: 20),
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
      const SizedBox(height: 8),
      Text(
        _quincenal && _primerDia >= _segundoDia
            ? 'El primer pago debe ir antes que el segundo'
            : 'Si cae fin de semana o festivo, contamos el día hábil anterior.',
        style: TextStyle(
          fontSize: 12,
          color: _quincenal && _primerDia >= _segundoDia
              ? context.c.textoPeligro
              : context.c.textoSuave,
        ),
      ),
    ],
  );

  Widget _pasoIngreso() => _Paso(
    titulo: '¿Cuánto te entra?',
    subtitulo: 'Lo que te llega en cada pago, ya con descuentos de nómina.',
    children: [
      TextField(
        controller: _ingresos,
        keyboardType: TextInputType.number,
        inputFormatters: const [MilesFormatter()],
        decoration: InputDecoration(
          labelText: _quincenal ? 'Ingreso por quincena' : 'Ingreso mensual',
          prefixText: r'$ ',
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 24),
      Porcentaje(
        icono: Icons.savings_outlined,
        titulo: '¿Cuánto quieres ahorrar?',
        valor: _ahorro,
        maximo: 50,
        monto: _plan.ahorro,
        onCambio: (v) => setState(() => _ahorro = v),
      ),
      Text(
        'Además apartamos un 5% para imprevistos. Todo esto lo cambias cuando quieras en Mi plan.',
        style: TextStyle(fontSize: 12, color: context.c.textoSuave),
      ),
    ],
  );

  Widget _pasoFijos() => _Paso(
    titulo: 'Tus gastos fijos',
    subtitulo: 'Arriendo, servicios, plan del celular, suscripciones… Si no los tienes a la mano, los agregas después.',
    children: [
      if (_fijos.isNotEmpty)
        Material(
          color: context.c.superficie,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final f in _fijos)
                ListTile(
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
        onPressed: _agregarFijo,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar gasto fijo'),
      ),
    ],
  );

  Widget _pasoListo() {
    final hoy = widget.ahora();
    final plan = _plan;
    final r = resumenDelDia(
      quincena: plan,
      gastos: const [],
      hoy: hoy,
      festivos: festivosColombiaAlrededorDe(hoy),
    );
    final ultimoDia = r.fin.subtract(const Duration(days: 1));
    final dias = r.diasRestantes == 1 ? '1 día' : '${r.diasRestantes} días';

    return _Paso(
      titulo: 'Listo, ${_nombre.text.trim()}',
      subtitulo: 'Esto es lo que puedes gastar hoy. Cambia cada día según lo que gastes.',
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.c.tarjeta,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoy puedes gastar',
                style: TextStyle(color: Colors.white70),
              ),
              FittedBox(
                child: Text(
                  formatoPesos(r.limiteHoy),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${plan.formaDePago.nombrePeriodo} · ${fechaCorta(r.inicio)} al ${fechaCorta(ultimoDia)}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '${formatoPesos(r.disponibleRestante)} para $dias',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (r.disponibleRestante < 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Tus gastos fijos y lo que separas superan tu ingreso. Revísalo en Mi plan.',
              style: TextStyle(color: context.c.textoPeligro),
            ),
          ),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({
    required this.titulo,
    required this.subtitulo,
    required this.children,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          subtitulo,
          style: TextStyle(
            fontSize: 15,
            color: context.c.textoSuave,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        ...children,
      ],
    );
  }
}
