import 'package:flutter/material.dart';

import '../datos_ejemplo.dart';
import '../models/festivos_colombia.dart';
import '../models/presupuesto.dart';
import '../tema.dart';
import '../utils/formato.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final resumen = resumenDelDia(
      quincena: quincenaEjemplo,
      gastos: gastosEjemplo(),
      hoy: hoy,
      festivos: festivosColombiaAlrededorDe(hoy),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _Encabezado(),
            const SizedBox(height: 20),
            _TarjetaQuincena(resumen: resumen),
            const SizedBox(height: 20),
            const _BotonAgregarGasto(),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: verde,
          child: Text(
            nombreUsuario[0],
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
                'Hola, $nombreUsuario',
                style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _TarjetaQuincena extends StatelessWidget {
  const _TarjetaQuincena({required this.resumen});

  final ResumenDelDia resumen;

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    final ultimoDia = r.fin.subtract(const Duration(days: 1));
    final dias = r.diasRestantes == 1 ? '1 día' : '${r.diasRestantes} días';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: azulOscuro,
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Etiqueta(
              icono: Icons.calendar_today_rounded,
              texto:
                  'Quincena actual · ${fechaCorta(r.inicio)} al ${fechaCorta(ultimoDia)}',
            ),
            const SizedBox(height: 16),
            const Text(
              'DISPONIBLE EN QUINCENA',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatoPesos(r.disponibleRestante),
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: r.disponibleRestante < 0 ? rojoSuave : Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('COP', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Te quedan ${formatoPesos(r.disponibleRestante)} para $dias',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Text(
              'Ya descontados los gastos fijos y el ahorro',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _RitmoDeGasto(resumen: r),
            const Divider(color: Colors.white24, height: 32),
            _LimiteDeHoy(resumen: r),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: verdeClaro),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _RitmoDeGasto extends StatelessWidget {
  const _RitmoDeGasto({required this.resumen});

  final ResumenDelDia resumen;

  @override
  Widget build(BuildContext context) {
    final bien = resumen.buenRitmo;
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Ritmo de gasto: ${resumen.porcentajeRestante}% restante',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const Spacer(),
            Text(
              bien ? 'Buen ritmo' : 'Vas rápido',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: bien ? verdeClaro : rojoSuave,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: resumen.porcentajeRestante / 100,
            minHeight: 8,
            backgroundColor: Colors.white12,
            color: bien ? verdeClaro : rojoSuave,
          ),
        ),
      ],
    );
  }
}

class _LimiteDeHoy extends StatelessWidget {
  const _LimiteDeHoy({required this.resumen});

  final ResumenDelDia resumen;

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    final pasado = r.quedaHoy < 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white12,
            child: Icon(Icons.payments_outlined, color: verdeClaro, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasado ? 'Hoy te pasaste' : 'Hoy puedes gastar',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  formatoPesos(r.quedaHoy.abs()),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: pasado ? rojoSuave : verdeClaro,
                  ),
                ),
                Text(
                  'Límite de hoy ${formatoPesos(r.limiteHoy)} · llevas ${formatoPesos(r.gastadoHoy)}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                if (r.apartado > 0)
                  Text(
                    'Apartado para programados: ${formatoPesos(r.apartado)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonAgregarGasto extends StatelessWidget {
  const _BotonAgregarGasto();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Muy pronto 😉')));
      },
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: verdeClaro,
            child: Icon(Icons.add, color: azulOscuro),
          ),
          SizedBox(width: 12),
          Text(
            'Agregar gasto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
