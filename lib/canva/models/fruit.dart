import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'gravitational_object.dart';

class Fruit extends GravitationalObject {
  Fruit({
 required this.width,
    required this.height,
    required Offset position,
    Offset additionalForce = const Offset(0, 0),
    double rotation = 0.25,
  required this.imageProvider,
  }) : super(
          position: position,
          gravitySpeed: Random().nextDouble() * 2 + 1, // Gravidade aleatória entre 1 e 3
          additionalForce: additionalForce,
          rotation: rotation,
        );

  final ImageProvider imageProvider;
  final double width;
  final double height;

  bool isPointInside(Offset point) {
    if (point.dx < position.dx) {
      return false;
    }

    if (point.dx > position.dx + width) {
      return false;
    }

    if (point.dy < position.dy) {
      return false;
    }

    if (point.dy > position.dy + height) {
      return false;
    }

    return true;
  }
}