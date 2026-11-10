import 'package:flutter/material.dart';

class Categoria {
  final String nombre;
  final String detalle;
  final IconData icono;
  final bool deQuincena;

  const Categoria(
    this.nombre,
    this.detalle,
    this.icono, {
    this.deQuincena = false,
  });
}

const categorias = [
  Categoria('Almuerzo', 'Corrientazo', Icons.restaurant_rounded),
  Categoria('Transporte', 'Bus / Taxi', Icons.directions_bus_rounded),
  Categoria(
    'Mercado',
    'Olímpica / D1',
    Icons.shopping_cart_rounded,
    deQuincena: true,
  ),
  Categoria(
    'Servicios',
    'Luz / Recargas',
    Icons.bolt_rounded,
    deQuincena: true,
  ),
  Categoria('Droguería', 'Farmacia', Icons.local_pharmacy_rounded),
  Categoria('Café / Snack', 'Merienda', Icons.coffee_rounded),
  Categoria('Mascota', 'Comida / Vet', Icons.pets_rounded),
];

const iconosParaOtros = [
  Icons.pets_rounded,
  Icons.card_giftcard_rounded,
  Icons.medical_services_rounded,
  Icons.school_rounded,
  Icons.checkroom_rounded,
  Icons.sports_esports_rounded,
  Icons.home_rounded,
  Icons.content_cut_rounded,
  Icons.sports_bar_rounded,
  Icons.sports_soccer_rounded,
  Icons.fitness_center_rounded,
  Icons.flight_rounded,
  Icons.directions_car_rounded,
  Icons.two_wheeler_rounded,
  Icons.build_rounded,
];

IconData iconoDe(String nombre, List<Categoria> propias) =>
    [...categorias, ...propias]
        .firstWhere(
          (c) => c.nombre == nombre,
          orElse: () => const Categoria('', '', Icons.receipt_long_rounded),
        )
        .icono;
