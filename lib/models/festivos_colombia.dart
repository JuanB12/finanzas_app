// Algoritmo de Meeus para la Pascua
DateTime domingoDePascua(int anio) {
  final a = anio % 19;
  final b = anio ~/ 100;
  final c = anio % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final mes = (h + l - 7 * m + 114) ~/ 31;
  final dia = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(anio, mes, dia);
}

// Ley Emiliani
DateTime _alLunes(DateTime dia) {
  final faltan = (DateTime.monday - dia.weekday) % 7;
  return DateTime(dia.year, dia.month, dia.day + faltan);
}

DateTime _mas(DateTime dia, int dias) =>
    DateTime(dia.year, dia.month, dia.day + dias);

Set<DateTime> festivosColombia(int anio) {
  final pascua = domingoDePascua(anio);
  return {
    DateTime(anio, 1, 1),
    DateTime(anio, 5, 1),
    DateTime(anio, 7, 20),
    DateTime(anio, 8, 7),
    DateTime(anio, 12, 8),
    DateTime(anio, 12, 25),

    _alLunes(DateTime(anio, 1, 6)), // Reyes
    _alLunes(DateTime(anio, 3, 19)), // San José
    _alLunes(DateTime(anio, 6, 29)), // San Pedro y San Pablo
    _alLunes(DateTime(anio, 8, 15)), // Asunción
    _alLunes(DateTime(anio, 10, 12)), // Día de la Raza
    _alLunes(DateTime(anio, 11, 1)), // Todos los Santos
    _alLunes(DateTime(anio, 11, 11)), // Independencia de Cartagena

    _mas(pascua, -3), // Jueves Santo
    _mas(pascua, -2), // Viernes Santo
    _alLunes(_mas(pascua, 39)), // Ascensión
    _alLunes(_mas(pascua, 60)), // Corpus Christi
    _alLunes(_mas(pascua, 68)), // Sagrado Corazón
  };
}

// Incluye el año siguiente para los pagos de fin de año
Set<DateTime> festivosColombiaAlrededorDe(DateTime dia) => {
  ...festivosColombia(dia.year),
  ...festivosColombia(dia.year + 1),
};
