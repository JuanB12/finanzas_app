import 'package:flutter/services.dart';

String formatoMiles(int valor) => valor.abs().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+$)'),
  (_) => '.',
);

String formatoPesos(int valor) =>
    '${valor < 0 ? '-' : ''}\$${formatoMiles(valor)}';

int leerMonto(String texto) =>
    int.tryParse(texto.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

// Pone los puntos de miles mientras el usuario escribe un monto
class MilesFormatter extends TextInputFormatter {
  const MilesFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) return TextEditingValue.empty;
    if (digitos.length > 12) return oldValue;

    final texto = formatoMiles(int.parse(digitos));
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
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
