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
}
