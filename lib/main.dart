import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FinanzasApp());
}

// Colores del diseño
const verde = Color(0xFF006C49);
const azulOscuro = Color(0xFF131B2E);
const fondo = Color(0xFFF8F9FF);

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
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis finanzas')),
      body: const Center(child: Text('Aquí va tu quincena 💰')),
    );
  }
}
