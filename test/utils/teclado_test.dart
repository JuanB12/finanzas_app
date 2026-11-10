import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/utils/teclado.dart';

void main() {
  test('Los dígitos se agregan a la derecha', () {
    expect(teclear(0, '1'), 1);
    expect(teclear(1, '2'), 12);
    expect(teclear(12, '0'), 120);
  });

  test('+000 agrega tres ceros', () {
    expect(teclear(12, '000'), 12000);
  });

  test('No hay ceros a la izquierda', () {
    expect(teclear(0, '0'), 0);
    expect(teclear(0, '000'), 0);
  });

  test('Borrar quita el último dígito', () {
    expect(teclear(12000, borrar), 1200);
    expect(teclear(5, borrar), 0);
    expect(teclear(0, borrar), 0);
  });

  test('No pasa de 9 dígitos', () {
    expect(teclear(999999999, '9'), 999999999);
    expect(teclear(1234567, '000'), 1234567);
  });
}
