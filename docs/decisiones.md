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
- **Modo oscuro:** antes, pasar los colores fijos (`Colors.white`, `Colors.black54`…) al tema.
- **Toques de Liquid Glass:** solo en piezas flotantes (barra de navegación), nunca detrás de los números de plata. Flutter no lo trae nativo: habría que imitarlo.
- **Compras grandes del día:** un mercado quincenal registrado hoy pone "Hoy te pasaste" en rojo aunque el ritmo de la quincena vaya bien. Pensar en marcarlas como gasto de la quincena, no del día.
- **Fondo de imprevistos:** un % de la quincena (lo configura el usuario, ej. 5%) para lo que no se planea: remedio del perro, una llanta. Al registrar un gasto se marca "Es un imprevisto" y sale del fondo, no del límite del día. Lo que sobra al final va al ahorro o al colchón. Hacerlo junto con la pantalla de configuración.
- **Por comprar (captura rápida):** anotar en 3 segundos algo que hay que comprar, con un valor aproximado. La plata se aparta de una y después se convierte en el gasto real. Necesita la base de datos.
- **Categorías propias:** hoy viven en memoria. Guardarlas cuando llegue la base de datos.
- **Crecimiento de Inicio:** barra de navegación abajo (Inicio, Movimientos, Presupuesto, Análisis), con el toque de Liquid Glass ahí. En Inicio solo los últimos 5 movimientos + "Ver todos". En Movimientos, agrupar por día.
- **Análisis:** en qué categorías se va la plata cada quincena.

## Orden acordado (2026-11-09)

1. Configuración de la quincena + fondo de imprevistos
2. Base de datos (SQLite)
3. Barra de navegación + pantalla de Movimientos
4. Análisis
