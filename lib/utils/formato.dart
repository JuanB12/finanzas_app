String formatoPesos(int valor) {
  final digitos = valor.abs().toString();
  final conPuntos = digitos.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => '.',
  );
  return '${valor < 0 ? '-' : ''}\$$conPuntos';
}

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String fechaCorta(DateTime fecha) => '${fecha.day} ${_meses[fecha.month - 1]}';
