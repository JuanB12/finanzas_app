import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../models/analisis.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../widgets/categorias.dart';

class AnalisisPage extends StatelessWidget {
  const AnalisisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);
    final resumen = finanzas.resumen;
    final hoy = finanzas.ahora();
    final a = analizar(
      gastos: finanzas.gastos,
      inicio: resumen.inicio,
      fin: resumen.fin,
      hoy: hoy,
    );
    final q = finanzas.quincena;
    final periodo = q.formaDePago.nombrePeriodo;
    final ultimoDia = resumen.fin.subtract(const Duration(days: 1));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Análisis',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          Text(
            '$periodo · ${fechaCorta(resumen.inicio)} al ${fechaCorta(ultimoDia)}',
            style: TextStyle(color: context.c.textoSuave),
          ),
          const SizedBox(height: 16),
          _Tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gastado hasta hoy',
                  style: TextStyle(color: context.c.textoSuave),
                ),
                Text(
                  formatoPesos(a.total),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'de ${formatoPesos(resumen.disponibleQuincena)} que tenías para gastar',
                  style: TextStyle(fontSize: 13, color: context.c.textoSuave),
                ),
                const Divider(height: 28),
                _Dato(
                  icono: Icons.savings_outlined,
                  texto: 'Ahorro separado',
                  valor: '${formatoPesos(q.ahorro)} (${q.porcentajeAhorro}%)',
                ),
                if (resumen.fondoImprevistos > 0)
                  _Dato(
                    icono: Icons.health_and_safety_outlined,
                    texto: 'Imprevistos usados',
                    valor:
                        '${formatoPesos(resumen.imprevistosUsados)} de ${formatoPesos(resumen.fondoImprevistos)}',
                  ),
              ],
            ),
          ),
          if (a.total == 0)
            Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Cuando registres gastos en esta quincena, aquí vas a ver en qué se te va la plata.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.c.textoTenue),
              ),
            )
          else ...[
            const SizedBox(height: 12),
            _Consejo(analisis: a, hoy: hoy),
            const _Titulo('¿En qué se te va la plata?'),
            _Tarjeta(
              child: _Barras(
                partes: a.porCategoria,
                icono: (nombre) => iconoDe(nombre, finanzas.categoriasPropias),
              ),
            ),
            const _Titulo('Gasto por día'),
            _Tarjeta(
              child: _GraficoDias(dias: a.porDia, hoy: hoy),
            ),
            const _Titulo('Por medio de pago'),
            _Tarjeta(child: _Barras(partes: a.porMedio)),
          ],
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.superficie,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto, required this.valor});

  final IconData icono;
  final String texto;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, size: 20, color: context.c.acento),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Consejo extends StatelessWidget {
  const _Consejo({required this.analisis, required this.hoy});

  final Analisis analisis;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final mayor = analisis.porCategoria.first;
    final peorDia = analisis.porDia.reduce((a, b) => b.monto > a.monto ? b : a);
    final variosDias = analisis.porDia.where((d) => d.monto > 0).length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.c.bordeConsejo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: verdeClaro),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu mayor gasto es ${mayor.nombre}: ${mayor.porcentaje}% de lo que llevas.'
              '${variosDias ? ' El día que más gastaste fue ${nombreDelDia(peorDia.dia, hoy).toLowerCase()}, con ${formatoPesos(peorDia.monto)}.' : ''}',
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// Una barra por parte, de mayor a menor. Un solo color: el nombre ya identifica
class _Barras extends StatelessWidget {
  const _Barras({required this.partes, this.icono});

  final List<Parte> partes;
  final IconData Function(String nombre)? icono;

  @override
  Widget build(BuildContext context) {
    final maximo = partes.first.monto;

    return Column(
      children: [
        for (final p in partes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                if (icono != null) ...[
                  Icon(icono!(p.nombre), size: 20, color: context.c.texto),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            formatoPesos(p.monto),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '${p.porcentaje}%',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: context.c.textoSuave),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(height: 8, color: context.c.pista),
                            FractionallySizedBox(
                              widthFactor: p.monto / maximo,
                              child: Container(
                                height: 8,
                                color: context.c.acento,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Barras por día. Tocar una muestra cuánto se gastó ese día
class _GraficoDias extends StatefulWidget {
  const _GraficoDias({required this.dias, required this.hoy});

  final List<DiaGastado> dias;
  final DateTime hoy;

  @override
  State<_GraficoDias> createState() => _GraficoDiasState();
}

class _GraficoDiasState extends State<_GraficoDias> {
  late int _elegido = widget.dias.length - 1; // hoy

  @override
  Widget build(BuildContext context) {
    final dias = widget.dias;
    final elegido = dias[_elegido.clamp(0, dias.length - 1)];
    final maximo = dias.fold(1, (m, d) => d.monto > m ? d.monto : m);
    const alto = 120.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${nombreDelDia(elegido.dia, widget.hoy)} · ${formatoPesos(elegido.monto)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          'Toca una barra para ver ese día',
          style: TextStyle(fontSize: 12, color: context.c.textoTenue),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: alto,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, d) in dias.indexed)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _elegido = i),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: d.monto == 0
                            ? 2
                            : (d.monto / maximo * alto).clamp(4, alto),
                        decoration: BoxDecoration(
                          color: d.monto == 0
                              ? context.c.pista
                              : i == _elegido
                              ? context.c.barraElegida
                              : context.c.acento,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              fechaCorta(dias.first.dia),
              style: TextStyle(fontSize: 12, color: context.c.textoTenue),
            ),
            const Spacer(),
            Text(
              nombreDelDia(dias.last.dia, widget.hoy),
              style: TextStyle(fontSize: 12, color: context.c.textoTenue),
            ),
          ],
        ),
      ],
    );
  }
}
