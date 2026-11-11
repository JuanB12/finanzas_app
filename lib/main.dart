import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'estado/finanzas.dart';
import 'screens/app_shell.dart';
import 'tema.dart';

void main() {
  runApp(FinanzasScope(finanzas: Finanzas(), child: const FinanzasApp()));
}

class FinanzasApp extends StatelessWidget {
  const FinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis finanzas',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: temaClaro,
      darkTheme: temaOscuro,
      themeMode: FinanzasScope.de(context).modoTema,
      home: const AppShell(),
    );
  }
}
