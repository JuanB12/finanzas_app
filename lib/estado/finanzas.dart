import 'package:flutter/widgets.dart';

import '../datos_ejemplo.dart';
import '../models/festivos_colombia.dart';
import '../models/gasto.dart';
import '../models/presupuesto.dart';
import '../models/quincena.dart';
import '../widgets/categorias.dart';

// El único dueño de los datos. Cuando algo cambia, avisa (notifyListeners)
// y todas las pantallas que lo usan se vuelven a dibujar.
// Por ahora en memoria: aquí es donde se conectará la base de datos.
class Finanzas extends ChangeNotifier {
  Finanzas({
    this.ahora = DateTime.now,
    this._nombre = nombreInicial,
    this._quincena = quincenaInicial,
  });

  final DateTime Function() ahora; // las pruebas pasan una fecha fija

  String _nombre;
  Quincena _quincena;
  final List<Gasto> _gastos = [];
  final List<Categoria> _categoriasPropias = [];

  String get nombre => _nombre;
  Quincena get quincena => _quincena;
  List<Gasto> get gastos => List.unmodifiable(_gastos);
  List<Categoria> get categoriasPropias =>
      List.unmodifiable(_categoriasPropias);

  Set<DateTime> get festivos => festivosColombiaAlrededorDe(ahora());

  ResumenDelDia get resumen => resumenDelDia(
    quincena: _quincena,
    gastos: _gastos,
    hoy: ahora(),
    festivos: festivos,
  );

  void cambiarNombre(String nombre) {
    _nombre = nombre;
    notifyListeners();
  }

  void cambiarPlan(Quincena quincena) {
    _quincena = quincena;
    notifyListeners();
  }

  void agregarGasto(Gasto gasto) {
    _gastos.add(gasto);
    notifyListeners();
  }

  void reemplazarGasto(Gasto viejo, Gasto nuevo) {
    _gastos[_gastos.indexOf(viejo)] = nuevo;
    notifyListeners();
  }

  // Devuelve la posición para poder deshacer
  int borrarGasto(Gasto gasto) {
    final posicion = _gastos.indexOf(gasto);
    _gastos.removeAt(posicion);
    notifyListeners();
    return posicion;
  }

  void insertarGasto(int posicion, Gasto gasto) {
    _gastos.insert(posicion, gasto);
    notifyListeners();
  }

  void agregarCategoria(Categoria categoria) {
    _categoriasPropias.add(categoria);
    notifyListeners();
  }
}

// Pone las finanzas al alcance de cualquier pantalla: Finanzas.de(context)
class FinanzasScope extends InheritedNotifier<Finanzas> {
  const FinanzasScope({
    super.key,
    required Finanzas finanzas,
    required super.child,
  }) : super(notifier: finanzas);

  static Finanzas de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FinanzasScope>()!.notifier!;
}
