import 'package:flutter/material.dart';

// Colores de marca: iguales en claro y en oscuro
const verde = Color(0xFF006C49);
const verdeClaro = Color(0xFF6CF8BB);
const azulOscuro = Color(0xFF131B2E);
const rojoSuave = Color(0xFFFF8A80);
const naranjaSuave = Color(0xFFFFC27A);

// Colores por función: cada pantalla pide "superficie" o "texto suave",
// y el tema decide cuál es en claro y cuál en oscuro
@immutable
class Colores extends ThemeExtension<Colores> {
  const Colores({
    required this.fondo,
    required this.superficie,
    required this.suave,
    required this.texto,
    required this.textoSuave,
    required this.textoTenue,
    required this.tarjeta,
    required this.primario,
    required this.sobrePrimario,
    required this.acentoSobrePrimario,
    required this.acento,
    required this.barraElegida,
    required this.pista,
    required this.aviso,
    required this.exito,
    required this.peligro,
    required this.textoPeligro,
    required this.textoProgramado,
    required this.bordeConsejo,
    required this.avatar,
  });

  final Color fondo; // detrás de todo
  final Color superficie; // tarjetas y listas
  final Color suave; // círculos de íconos, teclas especiales
  final Color texto;
  final Color textoSuave;
  final Color textoTenue;
  final Color tarjeta; // la tarjeta oscura de Inicio
  final Color primario; // botones principales
  final Color sobrePrimario; // texto sobre el botón principal
  final Color acentoSobrePrimario; // el "+" y el monto del botón
  final Color acento; // íconos y barras de marca
  final Color barraElegida;
  final Color pista; // fondo de las barras de progreso
  final Color aviso; // "tienes cambios sin guardar"
  final Color exito; // "En meta"
  final Color peligro; // "Te pasas"
  final Color textoPeligro;
  final Color textoProgramado;
  final Color bordeConsejo; // en oscuro la tarjeta del consejo necesita borde
  final Color avatar; // el círculo con tu inicial

  static const claro = Colores(
    fondo: Color(0xFFF8F9FF),
    superficie: Colors.white,
    suave: Color(0xFFE3EBFF),
    texto: azulOscuro,
    textoSuave: Color(0x8A000000),
    textoTenue: Color(0x73000000),
    tarjeta: azulOscuro,
    primario: Colors.black,
    sobrePrimario: Colors.white,
    acentoSobrePrimario: verdeClaro,
    acento: verde,
    barraElegida: Color(0xFF004D34),
    pista: Color(0xFFE6EBF5),
    aviso: Color(0xFFFFF4E0),
    exito: Color(0xFFD1FAE5),
    peligro: Color(0xFFFFE4E1),
    textoPeligro: Color(0xFFD32F2F),
    textoProgramado: Color(0xFFE65100),
    bordeConsejo: Colors.transparent,
    avatar: verde,
  );

  static const oscuro = Colores(
    fondo: Color(0xFF0B1120),
    superficie: Color(0xFF172033),
    suave: Color(0xFF243150),
    texto: Color(0xFFE8ECF5),
    textoSuave: Color(0xB3FFFFFF),
    textoTenue: Color(0x8AFFFFFF),
    tarjeta: Color(
      0xFF1E2A44,
    ), // un poco más clara que el fondo para que se note
    primario: verdeClaro,
    sobrePrimario: Color(0xFF0B1120),
    acentoSobrePrimario: Color(0xFF0B1120),
    acento: verdeClaro,
    barraElegida: Color(0xFFB4FFDD),
    pista: Color(0xFF2A3550),
    aviso: Color(0xFF3A2E14),
    exito: Color(0xFF12382A),
    peligro: Color(0xFF3D1E22),
    textoPeligro: rojoSuave,
    textoProgramado: naranjaSuave,
    bordeConsejo: Color(0x596CF8BB), // verde menta al 35%
    avatar: Color(0xFF12A070), // más claro para que se note en el fondo oscuro
  );

  @override
  Colores copyWith() => this;

  @override
  Colores lerp(Colores? otro, double t) {
    if (otro == null) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return Colores(
      fondo: m(fondo, otro.fondo),
      superficie: m(superficie, otro.superficie),
      suave: m(suave, otro.suave),
      texto: m(texto, otro.texto),
      textoSuave: m(textoSuave, otro.textoSuave),
      textoTenue: m(textoTenue, otro.textoTenue),
      tarjeta: m(tarjeta, otro.tarjeta),
      primario: m(primario, otro.primario),
      sobrePrimario: m(sobrePrimario, otro.sobrePrimario),
      acentoSobrePrimario: m(acentoSobrePrimario, otro.acentoSobrePrimario),
      acento: m(acento, otro.acento),
      barraElegida: m(barraElegida, otro.barraElegida),
      pista: m(pista, otro.pista),
      aviso: m(aviso, otro.aviso),
      exito: m(exito, otro.exito),
      peligro: m(peligro, otro.peligro),
      textoPeligro: m(textoPeligro, otro.textoPeligro),
      textoProgramado: m(textoProgramado, otro.textoProgramado),
      bordeConsejo: m(bordeConsejo, otro.bordeConsejo),
      avatar: m(avatar, otro.avatar),
    );
  }
}

extension ColoresDelTema on BuildContext {
  Colores get c => Theme.of(this).extension<Colores>() ?? Colores.claro;
}

ThemeData _tema(Brightness brillo, Colores c) => ThemeData(
  brightness: brillo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: verde,
    brightness: brillo,
    primary: c.acento,
    onPrimary: c.sobrePrimario,
    surface: c.fondo,
    onSurface: c.texto,
  ),
  scaffoldBackgroundColor: c.fondo,
  fontFamily: 'PlusJakartaSans',
  extensions: [c],
);

final temaClaro = _tema(Brightness.light, Colores.claro);
final temaOscuro = _tema(Brightness.dark, Colores.oscuro);
