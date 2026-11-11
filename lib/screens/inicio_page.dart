import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../models/forma_de_pago.dart';
import '../models/presupuesto.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../widgets/movimiento_tile.dart';
import 'configuracion_app_page.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key, required this.onVerTodos});

  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Encabezado(nombre: finanzas.nombre),
          const SizedBox(height: 20),
          _TarjetaQuincena(
            resumen: finanzas.resumen,
            forma: finanzas.quincena.formaDePago,
          ),
          const SizedBox(height: 28),
          _UltimosMovimientos(onVerTodos: onVerTodos),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.nombre});

  final String nombre;

  void _abrirConfiguracion(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ConfiguracionAppPage()),
  );

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _abrirConfiguracion(context),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: context.c.avatar,
                  child: Text(
                    nombre[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido', style: textos.bodySmall),
                      Text(
                        'Hola, $nombre',
                        overflow: TextOverflow.ellipsis,
                        style: textos.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Configuración de la app',
          onPressed: () => _abrirConfiguracion(context),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _TarjetaQuincena extends StatelessWidget {
  const _TarjetaQuincena({required this.resumen, required this.forma});

  final ResumenDelDia resumen;
  final FormaDePago forma;

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    final ultimoDia = r.fin.subtract(const Duration(days: 1));
    final dias = r.diasRestantes == 1 ? '1 día' : '${r.diasRestantes} días';

    final (titulo, color) = switch (r.estadoHoy) {
      EstadoHoy.bien => ('Hoy puedes gastar', Colors.white),
      EstadoHoy.pasadoPeroVasBien => (
        'Te pasaste hoy, pero vas bien 👍',
        naranjaSuave,
      ),
      EstadoHoy.pasado => ('Hoy te pasaste', rojoSuave),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.c.tarjeta,
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(color: Colors.white70)),
            FittedBox(
              child: Text(
                formatoPesos(r.quedaHoy.abs()),
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: color,
                ),
              ),
            ),
            Text(
              'Límite de hoy ${formatoPesos(r.limiteHoy)} · llevas ${formatoPesos(r.gastadoHoy)}',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const Divider(color: Colors.white24, height: 36),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${forma.nombrePeriodo} · ${fechaCorta(r.inicio)} al ${fechaCorta(ultimoDia)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${formatoPesos(r.disponibleRestante)} para $dias',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: r.disponibleRestante < 0
                              ? rojoSuave
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                _Ritmo(bueno: r.buenRitmo),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: r.porcentajeRestante / 100,
                minHeight: 6,
                backgroundColor: Colors.white12,
                color: r.buenRitmo ? verdeClaro : rojoSuave,
              ),
            ),
            if (r.apartado > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Apartado para ${forma.elPeriodo}: ${formatoPesos(r.apartado)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (r.fondoImprevistos > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.health_and_safety_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Imprevistos: te quedan ${formatoPesos(r.imprevistosRestantes)} de ${formatoPesos(r.fondoImprevistos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Ritmo extends StatelessWidget {
  const _Ritmo({required this.bueno});

  final bool bueno;

  @override
  Widget build(BuildContext context) {
    final color = bueno ? verdeClaro : rojoSuave;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        bueno ? 'Buen ritmo' : 'Vas rápido',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _UltimosMovimientos extends StatelessWidget {
  const _UltimosMovimientos({required this.onVerTodos});

  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    final gastos = FinanzasScope.de(context).gastos;
    final recientes = gastos.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Últimos movimientos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            if (gastos.isNotEmpty)
              TextButton(
                onPressed: onVerTodos,
                child: Text('Ver todos (${gastos.length}) →'),
              ),
          ],
        ),
        if (recientes.isNotEmpty)
          Text(
            'Toca para editar · desliza a la izquierda para borrar',
            style: TextStyle(fontSize: 12, color: context.c.textoTenue),
          ),
        const SizedBox(height: 12),
        if (recientes.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Todavía no has registrado gastos',
                style: TextStyle(color: context.c.textoTenue),
              ),
            ),
          )
        else
          Material(
            color: context.c.superficie,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [for (final g in recientes) MovimientoTile(gasto: g)],
            ),
          ),
      ],
    );
  }
}
