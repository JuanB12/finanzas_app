enum Frecuencia { quincenal, mensual }

// 31 = último día del mes (en febrero es el 28 o el 29)
const ultimoDia = 31;

class FormaDePago {
  final Frecuencia frecuencia;
  final int primerDia;
  final int? segundoDia; // null si es mensual

  const FormaDePago.quincenal({
    this.primerDia = 15,
    int this.segundoDia = ultimoDia,
  }) : frecuencia = Frecuencia.quincenal;

  const FormaDePago.mensual({int dia = ultimoDia})
    : frecuencia = Frecuencia.mensual,
      primerDia = dia,
      segundoDia = null;

  List<int> get diasDePago => [primerDia, ?segundoDia];

  bool get _quincenal => frecuencia == Frecuencia.quincenal;

  String get nombrePeriodo => _quincenal ? 'Quincena' : 'Mes';

  // "quincena" es femenino y "mes" masculino
  String get este => _quincenal ? 'Esta quincena' : 'Este mes';
  String get proximo => _quincenal ? 'Próxima quincena' : 'Próximo mes';
  String get elPeriodo => _quincenal ? 'la quincena' : 'el mes';
  String get todoElPeriodo => _quincenal ? 'toda la quincena' : 'todo el mes';
}
