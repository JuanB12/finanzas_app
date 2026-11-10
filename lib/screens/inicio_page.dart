import 'package:flutter/material.dart';

import '../datos_ejemplo.dart';
import '../models/festivos_colombia.dart';
import '../models/gasto.dart';
import '../models/presupuesto.dart';
import '../tema.dart';
import '../utils/formato.dart';
import '../widgets/categorias.dart';
import 'registrar_gasto_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  // Por ahora en memoria: se pierden al cerrar la app
  final List<Gasto> _gastos = [];
  final List<Categoria> _categoriasPropias = [];

  Future<void> _abrirRegistro({Gasto? editar}) async {
    final gasto = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RegistrarGastoPage(
          // Al editar, la vista previa no debe contar el gasto dos veces
          gastos: [
            for (final g in _gastos)
              if (!identical(g, editar)) g,
          ],
          categoriasPropias: _categoriasPropias,
          onNuevaCategoria: _categoriasPropias.add,
          inicial: editar,
        ),
      ),
    );
    if (gasto == null || !mounted) return;

    setState(() {
      if (editar == null) {
        _gastos.add(gasto);
      } else {
        _gastos[_gastos.indexOf(editar)] = gasto;
      }
    });
  }

  void _borrar(Gasto gasto) {
    final posicion = _gastos.indexOf(gasto);
    setState(() => _gastos.removeAt(posicion));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Borraste ${gasto.descripcion}'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => setState(() => _gastos.insert(posicion, gasto)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final resumen = resumenDelDia(
      quincena: quincenaEjemplo,
      gastos: _gastos,
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
            _BotonAgregarGasto(onPressed: _abrirRegistro),
            const SizedBox(height: 28),
            _UltimosMovimientos(
              gastos: _gastos,
              categoriasPropias: _categoriasPropias,
              resumen: resumen,
              onEditar: (g) => _abrirRegistro(editar: g),
              onBorrar: _borrar,
            ),
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
        color: azulOscuro,
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
                        'Quincena · ${fechaCorta(r.inicio)} al ${fechaCorta(ultimoDia)}',
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
                'Apartado para la quincena: ${formatoPesos(r.apartado)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
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

class _BotonAgregarGasto extends StatelessWidget {
  const _BotonAgregarGasto({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
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

class _UltimosMovimientos extends StatelessWidget {
  const _UltimosMovimientos({
    required this.gastos,
    required this.categoriasPropias,
    required this.resumen,
    required this.onEditar,
    required this.onBorrar,
  });

  final List<Gasto> gastos;
  final List<Categoria> categoriasPropias;
  final ResumenDelDia resumen;
  final ValueChanged<Gasto> onEditar;
  final ValueChanged<Gasto> onBorrar;

  String _etiqueta(Gasto g) {
    final cual = switch (resumen.cualQuincena(g.fecha)) {
      CualQuincena.pasada => 'Quincena pasada',
      CualQuincena.proxima => 'Próxima quincena',
      CualQuincena.actual when g.programado => 'Programado',
      CualQuincena.actual when g.deQuincena => 'De la quincena',
      CualQuincena.actual => null,
    };
    return [?cual, g.medioPago.nombre].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final recientes = gastos.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimos movimientos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (recientes.isNotEmpty)
          const Text(
            'Toca para editar · desliza a la izquierda para borrar',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        const SizedBox(height: 12),
        if (recientes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Todavía no has registrado gastos',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          )
        else
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final g in recientes)
                  Dismissible(
                    key: ObjectKey(g),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => onBorrar(g),
                    background: Container(
                      color: Colors.red.shade400,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => onEditar(g),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE3EBFF),
                        child: Icon(
                          iconoDe(g.descripcion, categoriasPropias),
                          color: azulOscuro,
                        ),
                      ),
                      title: Text(
                        g.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _etiqueta(g),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '-${formatoPesos(g.monto)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            fechaCorta(g.fecha),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
