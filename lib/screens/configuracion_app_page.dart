import 'package:flutter/material.dart';

import '../estado/finanzas.dart';
import '../tema.dart';

const versionApp = '1.0.0';

class ConfiguracionAppPage extends StatelessWidget {
  const ConfiguracionAppPage({super.key});

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
              backgroundColor: verde,
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
          const _Grupo(
            titulo: 'Preferencias',
            children: [
              _Opcion(
                icono: Icons.dark_mode_outlined,
                titulo: 'Apariencia',
                detalle: 'Claro',
                pronto: true,
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
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Material(
          color: Colors.white,
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
      leading: Icon(icono, color: verde),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detalle),
      trailing: pronto
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EBFF),
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
