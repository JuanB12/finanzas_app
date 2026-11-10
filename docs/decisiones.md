# Decisiones del proyecto

Registro de las decisiones importantes: qué decidimos, por qué y qué descartamos.

## 2026-11-09 · Límite diario dinámico

- **Decisión:** límite de hoy = (disponible − lo gastado antes de hoy) ÷ días que faltan.
- **Por qué:** un límite fijo miente: si gastas de más un día, la app debe bajar los días que quedan. Si ahorras, suben.
- **Detalle:** lo gastado hoy no cambia el límite de hoy, se descuenta de "te queda hoy". Así el número no salta mientras registras gastos.
- **Descartado:** disponible ÷ días, calculado una sola vez por quincena.

## 2026-11-09 · Festivos calculados, no escritos a mano

- **Decisión:** calcular los festivos de Colombia: fijos, Ley Emiliani (corridos al lunes) y los que dependen de la Pascua (algoritmo de Meeus).
- **Por qué:** sirven para cualquier año sin actualizar la app.
- **A futuro:** otros países = otra función `festivosMexico(anio)`. El calendario de pagos recibe los festivos como parámetro y no sabe de qué país son.

## 2026-11-09 · Ingresos extra van al colchón

- **Decisión:** la prima, las cesantías y las ventas van a un colchón aparte y nunca suben el límite diario.
- **Por qué:** en diciembre la app no debe decir "gasta $200.000 al día".
- **Pendiente:** definir para qué se usa el colchón (¿metas?, ¿emergencias?).

## 2026-11-09 · Reglas de pago (Colombia, quincenal)

- Se paga el 15 y el último día del mes. Si es sábado, domingo o festivo, se paga el día hábil anterior.
- Hoy cuenta como día para gastar. El día de pago ya es de la quincena nueva.
- **A futuro:** pago mensual (selector en la configuración).

## Convenciones

- La plata se guarda en `int` (pesos COP, sin decimales). Multimoneda: más adelante.
- TDD: primero la prueba en rojo, después el código.

## Pendientes (backlog)

- **Días de pago configurables:** quincenal con cualquier par de días (15/30, 5/20, 10/25) y mensual. Se hace junto con la pantalla de configuración.
- **Ingresos variables:** para independientes y freelancers. Necesita su propio debate.
- **Destino de un ingreso extra:** al registrarlo, el usuario elige si va al colchón o a la quincena actual (en ese caso el límite se recalcula).
- **Gastos programados:** un gasto con fecha futura dentro de la quincena debe apartarse desde ya, no ignorarse hasta ese día.
- **Validar con usuarios reales:** preguntarles a 3 a 5 personas cómo les pagan y cómo controlan su plata.
