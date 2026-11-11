import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../models/gasto.dart';
import '../models/movimientos.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../widgets/movimiento_tile.dart';

class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  final _busqueda = TextEditingController();
  String? _categoria;
  MedioPago? _medio;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  bool get _hayFiltros =>
      _busqueda.text.isNotEmpty || _categoria != null || _medio != null;

  void _limpiar() => setState(() {
    _busqueda.clear();
    _categoria = null;
    _medio = null;
  });

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);
    final todos = finanzas.gastos;
    final filtrados = filtrarGastos(
      todos,
      texto: _busqueda.text,
      categoria: _categoria,
      medio: _medio,
    );
    final grupos = agruparPorDia(filtrados);
    final categoriasUsadas = {for (final g in todos) g.descripcion}.toList()
      ..sort();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Movimientos',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
                if (_hayFiltros)
                  TextButton(onPressed: _limpiar, child: const Text('Limpiar')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar (ej. Bruno, mercado)',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: context.c.superficie,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _FilaDeFiltros(
            children: [
              for (final m in MedioPago.values)
                FilterChip(
                  label: Text(m.nombre),
                  selected: _medio == m,
                  onSelected: (s) => setState(() => _medio = s ? m : null),
                ),
            ],
          ),
          if (categoriasUsadas.length > 1)
            _FilaDeFiltros(
              children: [
                for (final c in categoriasUsadas)
                  FilterChip(
                    label: Text(c),
                    selected: _categoria == c,
                    onSelected: (s) =>
                        setState(() => _categoria = s ? c : null),
                  ),
              ],
            ),
          Expanded(
            child: grupos.isEmpty
                ? _Vacio(hayFiltros: _hayFiltros)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      if (_hayFiltros)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${filtrados.length} de ${todos.length} · ${formatoPesos(filtrados.fold(0, (s, g) => s + g.monto))}',
                            style: TextStyle(color: context.c.textoSuave),
                          ),
                        ),
                      for (final grupo in grupos) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nombreDelDia(grupo.dia, finanzas.ahora()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                formatoPesos(grupo.total),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: context.c.texto,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: context.c.superficie,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (final g in grupo.gastos)
                                MovimientoTile(gasto: g, conFecha: false),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilaDeFiltros extends StatelessWidget {
  const _FilaDeFiltros({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        children: [
          for (final c in children)
            Padding(padding: const EdgeInsets.only(right: 8), child: c),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.hayFiltros});

  final bool hayFiltros;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          hayFiltros ? 'Ningún gasto coincide con la búsqueda' : 'Todavía no has registrado gastos.\nToca "Agregar gasto" para empezar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.c.textoTenue),
        ),
      ),
    );
  }
}
