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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
          primary: verde,
          surface: fondo,
          onSurface: azulOscuro,
        ),
        scaffoldBackgroundColor: fondo,
        fontFamily: 'PlusJakartaSans',
      ),
      home: const AppShell(),
    );
  }
}
