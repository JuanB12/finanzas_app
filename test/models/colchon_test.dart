import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/colchon.dart';

void main() {
  test('El colchón suma todos los ingresos extra', () {
    final colchon = Colchon(
      ingresos: [
        IngresoExtra(
          nombre: 'Prima de junio',
          monto: 400000,
          fecha: DateTime(2026, 6, 30),
        ),
        IngresoExtra(
          nombre: 'Prima de diciembre',
          monto: 400000,
          fecha: DateTime(2026, 12, 18),
        ),
        IngresoExtra(
          nombre: 'Venta de la bici',
          monto: 250000,
          fecha: DateTime(2026, 9, 3),
        ),
      ],
    );
    expect(colchon.total, 1050000);
  });

  test('Un colchón vacío vale 0', () {
    expect(const Colchon(ingresos: []).total, 0);
  });
}
