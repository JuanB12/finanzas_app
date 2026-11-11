import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/utils/formato.dart';

void main() {
  group('Pesos', () {
    test('Separa los miles con punto', () {
      expect(formatoPesos(319000), r'$319.000');
      expect(formatoPesos(1234567), r'$1.234.567');
    });

    test('Cero y valores pequeños', () {
      expect(formatoPesos(0), r'$0');
      expect(formatoPesos(500), r'$500');
    });

    test('Los negativos llevan el signo antes del peso', () {
      expect(formatoPesos(-29700), r'-$29.700');
    });
  });

  test('Fecha corta en español', () {
    expect(fechaCorta(DateTime(2026, 10, 30)), '30 oct');
    expect(fechaCorta(DateTime(2027, 1, 5)), '5 ene');
  });

  group('Escribir montos', () {
    TextEditingValue escribir(String texto) =>
        const MilesFormatter().formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: texto),
        );

    test('Pone los puntos de miles mientras escribes', () {
      expect(escribir('797000').text, '797.000');
      expect(escribir('1234567').text, '1.234.567');
      expect(escribir('500').text, '500');
    });

    test('Ignora lo que no sea número y deja el cursor al final', () {
      final v = escribir('79.70a00');
      expect(v.text, '797.000');
      expect(v.selection.baseOffset, 7);
    });

    test('Vacío se queda vacío', () {
      expect(escribir('').text, '');
    });

    test('Leer el monto quita los puntos', () {
      expect(leerMonto('797.000'), 797000);
      expect(leerMonto(''), 0);
    });
  });
}
