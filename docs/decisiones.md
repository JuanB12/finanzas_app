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
- **Qué debe guardar la base de datos:** gastos, el plan (ingreso, forma de pago, ahorro, imprevistos, gastos fijos), las categorías propias, el nombre y la **apariencia** (claro/oscuro/automático). Hoy todo vuelve al valor inicial al cerrar la app; en el caso de la apariencia, vuelve a "Automático".
- **Crecimiento de Inicio:** barra de navegación abajo (Inicio, Movimientos, Presupuesto, Análisis), con el toque de Liquid Glass ahí. En Inicio solo los últimos 5 movimientos + "Ver todos". En Movimientos, agrupar por día.
- **Análisis:** en qué categorías se va la plata cada quincena.

- **Gastos fijos mensuales con pago quincenal:** el gimnasio se paga una vez al mes, pero hoy la app lo descuenta de cada quincena. Hay que decidir en qué quincena se cobra cada gasto fijo.
- **Nombre de la clase `Quincena`:** ahora también representa un mes (pago mensual). Renombrarla a algo como `Periodo` cuando haya un momento tranquilo.
- **Sobrante del fondo de imprevistos:** al cerrar el periodo, mandarlo al ahorro o al colchón. Necesita la base de datos para recordar el periodo anterior.

## 2026-11-10 · Configuración y fondo de imprevistos

- **Forma de pago:** quincenal con dos días cualesquiera, o mensual con un día. El 31 significa "último día del mes".
- **Selector quincenal/mensual:** botón segmentado, no checklist ni combobox (son solo 2 opciones excluyentes). Los días sí van en lista desplegable.
- **Imprevistos:** un % del ingreso que se separa como el ahorro. Un gasto marcado como imprevisto sale primero del fondo. Si no alcanza, lo que falta se reparte en el periodo.

## 2026-11-10 · Mi plan vs. configuración de la app

- **Decisión:** separar lo financiero de lo de la app. La pestaña **Mi plan** (💼) tiene ingreso, forma de pago, ahorro, imprevistos y gastos fijos. La **configuración de la app** (perfil, apariencia, notificaciones, moneda, acerca de) se abre desde el círculo con tu inicial o el ⚙️ en Inicio.
- **Por qué:** son cosas distintas y se tocan con distinta frecuencia. Idea de Juan.
- **A futuro:** las metas de ahorro y los topes por categoría van dentro de Mi plan, no en una quinta pestaña.

## 2026-11-10 · Metas de ahorro y topes (próxima pantalla, dentro de Mi plan)

- **Metas: "aparto X cada quincena"**, no "lo que sobre". El aporte a cada meta se separa apenas llega el pago, como el ahorro, y baja el disponible. Así la meta avanza sí o sí; lo que sobra casi nunca existe.
- **Fecha estimada:** con el aporte por quincena, la app calcula cuándo llegarías ("en 5 quincenas, para el 15 de enero").
- **Más adelante (con base de datos):** sumar a la meta lo que sobre al cerrar la quincena, como bonus.
- **Topes por categoría:** un máximo por periodo (ej. Domicilios $80.000). En Registrar gasto se avisa desde el 80% del tope.
- **El colchón** (prima, cesantías) se muestra en la misma pantalla.

## Orden acordado (2026-11-09)

1. Configuración de la quincena + fondo de imprevistos
2. Base de datos (SQLite)
3. Barra de navegación + pantalla de Movimientos
4. Análisis
