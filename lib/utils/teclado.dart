const borrar = '⌫';
const _maxDigitos = 9;

int teclear(int monto, String tecla) {
  if (tecla == borrar) return monto ~/ 10;

  final nuevo = int.parse('$monto$tecla');
  return nuevo.toString().length > _maxDigitos ? monto : nuevo;
}
