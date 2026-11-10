import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/festivos_colombia.dart';

void main() {
  group('Domingo de Pascua', () {
    test('Coincide con el calendario real de varios años', () {
      expect(domingoDePascua(2024), DateTime(2024, 3, 31));
      expect(domingoDePascua(2025), DateTime(2025, 4, 20));
      expect(domingoDePascua(2026), DateTime(2026, 4, 5));
      expect(domingoDePascua(2027), DateTime(2027, 3, 28));
    });
  });

  group('Festivos de Colombia', () {
    test('2026 tiene los 18 festivos oficiales', () {
      expect(festivosColombia(2026), {
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 12),
        DateTime(2026, 3, 23),
        DateTime(2026, 4, 2),
        DateTime(2026, 4, 3),
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 18),
        DateTime(2026, 6, 8),
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 29),
        DateTime(2026, 7, 20),
        DateTime(2026, 8, 7),
        DateTime(2026, 8, 17),
        DateTime(2026, 10, 12),
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 16),
        DateTime(2026, 12, 8),
        DateTime(2026, 12, 25),
      });
    });

    test('Un festivo que ya cae lunes no se corre una semana', () {
      expect(festivosColombia(2026), contains(DateTime(2026, 10, 12)));
      expect(festivosColombia(2026), isNot(contains(DateTime(2026, 10, 19))));
    });

    test('Los festivos fijos no se corren aunque caigan entre semana', () {
      // 20 de julio de 2027 es martes y sigue siendo 20 de julio
      expect(festivosColombia(2027), contains(DateTime(2027, 7, 20)));
    });
  });
}
