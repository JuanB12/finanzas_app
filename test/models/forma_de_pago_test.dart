import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/forma_de_pago.dart';

void main() {
  test('Quincena es femenino', () {
    const f = FormaDePago.quincenal();
    expect(f.este, 'Esta quincena');
    expect(f.proximo, 'Próxima quincena');
    expect(f.elPeriodo, 'la quincena');
    expect(f.todoElPeriodo, 'toda la quincena');
  });

  test('Mes es masculino', () {
    const f = FormaDePago.mensual();
    expect(f.este, 'Este mes');
    expect(f.proximo, 'Próximo mes');
    expect(f.elPeriodo, 'el mes');
    expect(f.todoElPeriodo, 'todo el mes');
  });
}
