import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../tema.dart';
import '../widgets/acciones_gasto.dart';
import 'analisis_page.dart';
import 'inicio_page.dart';
import 'mi_plan_page.dart';
import 'movimientos_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _pestana = 0;

  void _ir(int pestana) => setState(() => _pestana = pestana);

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);

    return Scaffold(
      // IndexedStack mantiene viva cada pestaña: al volver, sigue como la dejaste
      body: IndexedStack(
        index: _pestana,
        children: [
          InicioPage(onVerTodos: () => _ir(1)),
          const MovimientosPage(),
          const AnalisisPage(),
          MiPlanPage(
            inicial: finanzas.quincena,
            onGuardar: finanzas.cambiarPlan,
            ahora: finanzas.ahora,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.c.superficie,
          border: Border(top: BorderSide(color: context.c.pista)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                _Pestana(
                  icono: Icons.home_outlined,
                  iconoActivo: Icons.home_rounded,
                  texto: 'Inicio',
                  activa: _pestana == 0,
                  onTap: () => _ir(0),
                ),
                _Pestana(
                  icono: Icons.receipt_long_outlined,
                  iconoActivo: Icons.receipt_long_rounded,
                  texto: 'Movimientos',
                  activa: _pestana == 1,
                  onTap: () => _ir(1),
                ),
                _BotonMas(onTap: () => abrirRegistro(context)),
                _Pestana(
                  icono: Icons.insights_outlined,
                  iconoActivo: Icons.insights_rounded,
                  texto: 'Análisis',
                  activa: _pestana == 2,
                  onTap: () => _ir(2),
                ),
                _Pestana(
                  icono: Icons.account_balance_wallet_outlined,
                  iconoActivo: Icons.account_balance_wallet_rounded,
                  texto: 'Mi plan',
                  activa: _pestana == 3,
                  onTap: () => _ir(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.icono,
    required this.iconoActivo,
    required this.texto,
    required this.activa,
    required this.onTap,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String texto;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activa ? context.c.texto : context.c.textoTenue;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: activa
                    ? verdeClaro.withValues(alpha: 0.4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(activa ? iconoActivo : icono, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonMas extends StatelessWidget {
  const _BotonMas({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Tooltip(
        message: 'Agregar gasto',
        child: Material(
          color: context.c.primario,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.add_rounded,
                color: context.c.acentoSobrePrimario,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
