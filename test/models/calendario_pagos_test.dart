import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas_app/models/calendario_pagos.dart';

// Reglas del calendario de pagos (Colombia, pago quincenal):
// 1. Hoy cuenta como día para gastar.
// 2. Se paga el 15 y el último día del mes (28, 29, 30 o 31).
// 3. Si el día de pago cae sábado, domingo o festivo, se paga el día hábil
//    anterior (si ese también es festivo, se sigue retrocediendo).
// 4. El día de pago ya es de la quincena nueva: ese día llega la plata.
void main() {
  group('Fin de semana y festivos (regla 3)', () {
    test('Si el 15 cae domingo, se paga el viernes antes', () {
      final hoy = DateTime(2026, 11, 8); // el 15 de nov. 2026 es domingo
      expect(proximoPago(hoy, festivos: {}), DateTime(2026, 11, 13));
    });

    test('Si el 15 cae sábado, se paga el viernes antes', () {
      final hoy = DateTime(2026, 8, 3); // el 15 de ago. 2026 es sábado
      expect(proximoPago(hoy, festivos: {}), DateTime(2026, 8, 14));
    });

    test('Si el 15 cae lunes festivo, se paga el viernes antes', () {
      final hoy = DateTime(2027, 2, 1); // el 15 de feb. 2027 es lunes
      expect(
        proximoPago(hoy, festivos: {DateTime(2027, 2, 15)}),
        DateTime(2027, 2, 12),
      );
    });

    test('Si el día de pago es festivo entre semana, se paga el día antes', () {
      final hoy = DateTime(2026, 12, 1); // el 15 de dic. 2026 es martes
      expect(
        proximoPago(hoy, festivos: {DateTime(2026, 12, 15)}),
        DateTime(2026, 12, 14),
      );
    });
  });

  group('Cuál quincena sigue (reglas 2 y 4)', () {
    test('Un día hábil normal se paga ese mismo día', () {
      final hoy = DateTime(2026, 12, 1);
      expect(proximoPago(hoy, festivos: {}), DateTime(2026, 12, 15));
    });

    test('Después del pago del 15, sigue el del fin de mes', () {
      final hoy = DateTime(2026, 11, 14);
      expect(proximoPago(hoy, festivos: {}), DateTime(2026, 11, 30));
    });
    test('El día de pago ya cuenta como quincena nueva', () {
      final hoy = DateTime(2026, 11, 13); // hoy pagaron
      expect(proximoPago(hoy, festivos: {}), DateTime(2026, 11, 30));
    });

    test(
      'En febrero, el fin de mes es el 28 (y si cae domingo, el viernes)',
      () {
        final hoy = DateTime(2027, 2, 16); // el 28 de feb. 2027 es domingo
        expect(proximoPago(hoy, festivos: {}), DateTime(2027, 2, 26));
      },
    );
  });

  group('Días para gastar hasta el pago (reglas 1 y 4)', () {
    test('Cuenta hoy, pero no el día de pago', () {
      final hoy = DateTime(2026, 11, 8); // pagan el vie 13: 8, 9, 10, 11 y 12
      expect(diasHastaPago(hoy, festivos: {}), 5);
    });

    test('El día de pago empieza una quincena nueva completa', () {
      final hoy = DateTime(2026, 11, 13); // del 13 al 29; pagan el 30
      expect(diasHastaPago(hoy, festivos: {}), 17);
    });

    test('La hora del día no cambia la cuenta', () {
      final hoy = DateTime(2026, 11, 8, 23, 59); // casi medianoche
      expect(diasHastaPago(hoy, festivos: {}), 5);
    });
  });
}
