import 'package:flutter/material.dart';

import 'screens/inicio_page.dart';
import 'tema.dart';

void main() {
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatelessWidget {
  const FinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis finanzas',
      debugShowCheckedModeBanner: false,
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
      home: const InicioPage(),
    );
  }
}
