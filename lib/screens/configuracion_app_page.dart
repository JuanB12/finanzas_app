import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../tema.dart';

const versionApp = '1.0.0';

const _nombresModo = {
  ThemeMode.system: 'Automático (como el teléfono)',
  ThemeMode.light: 'Claro',
  ThemeMode.dark: 'Oscuro',
};

class ConfiguracionAppPage extends StatelessWidget {
  const ConfiguracionAppPage({super.key});

  Future<void> _elegirApariencia(BuildContext context) async {
    final finanzas = FinanzasScope.de(context);
    final modo = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Apariencia'),
        children: [
          for (final MapEntry(key: m, value: nombre) in _nombresModo.entries)
            ListTile(
              title: Text(nombre),
              leading: Icon(
                m == finanzas.modoTema
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: context.c.acento,
              ),
              onTap: () => Navigator.pop(context, m),
            ),
        ],
      ),
    );
    if (modo != null) finanzas.cambiarModoTema(modo);
  }

  Future<void> _cambiarNombre(BuildContext context) async {
    final finanzas = FinanzasScope.de(context);
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => _NombreDialog(actual: finanzas.nombre),
    );
    if (nombre != null) finanzas.cambiarNombre(nombre);
  }

  @override
  Widget build(BuildContext context) {
    final finanzas = FinanzasScope.de(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: context.c.avatar,
              child: Text(
                finanzas.nombre[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              finanzas.nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
          _Grupo(
            titulo: 'Perfil',
            children: [
              _Opcion(
                icono: Icons.person_outline_rounded,
                titulo: 'Nombre',
                detalle: finanzas.nombre,
                onTap: () => _cambiarNombre(context),
              ),
            ],
          ),
          _Grupo(
            titulo: 'Preferencias',
            children: [
              _Opcion(
                icono: Icons.dark_mode_outlined,
                titulo: 'Apariencia',
                detalle: _nombresModo[finanzas.modoTema]!,
                onTap: () => _elegirApariencia(context),
              ),
              _Opcion(
                icono: Icons.notifications_none_rounded,
                titulo: 'Notificaciones',
                detalle: 'Avisos de cobros y del día de pago',
                pronto: true,
              ),
              _Opcion(
                icono: Icons.payments_outlined,
                titulo: 'Moneda',
                detalle: 'Peso colombiano (COP)',
              ),
            ],
          ),
          const _Grupo(
            titulo: 'La app',
            children: [
              _Opcion(
                icono: Icons.info_outline_rounded,
                titulo: 'Acerca de',
                detalle: 'Mis finanzas · versión $versionApp',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            titulo.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              color: context.c.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Material(
          color: context.c.superficie,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.onTap,
    this.pronto = false,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback? onTap;
  final bool pronto;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icono, color: context.c.acento),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detalle),
      trailing: pronto
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.c.suave,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Pronto',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            )
          : onTap != null
          ? const Icon(Icons.chevron_right_rounded)
          : null,
    );
  }
}

class _NombreDialog extends StatefulWidget {
  const _NombreDialog({required this.actual});

  final String actual;

  @override
  State<_NombreDialog> createState() => _NombreDialogState();
}

class _NombreDialogState extends State<_NombreDialog> {
  late final _nombre = TextEditingController(text: widget.actual);

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _nombre.text.trim();
    return AlertDialog(
      title: const Text('Tu nombre'),
      content: TextField(
        controller: _nombre,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: nombre.isEmpty
              ? null
              : () => Navigator.pop(context, nombre),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
