import 'dart:math';

import 'package:flutter/material.dart';

class SliceColorPalette {
  static const List<Color> premiumColors = <Color>[
    Color(0xFFFF6B6B),
    Color(0xFFFF8E53),
    Color(0xFFFFC75F),
    Color(0xFF7BD389),
    Color(0xFF40C9A2),
    Color(0xFF4AA3FF),
    Color(0xFF6C63FF),
    Color(0xFFB48EFF),
    Color(0xFFF28BC5),
    Color(0xFF78D9EC),
  ];

  static int colorForIndex(int index) {
    return premiumColors[index % premiumColors.length].value;
  }

  static List<int> shuffledColorValues(int count, {Random? random}) {
    final seededRandom = random ?? Random();
    final colors = List<Color>.from(premiumColors)..shuffle(seededRandom);
    return List<int>.generate(
      count,
      (index) => colors[index % colors.length].value,
    );
  }
}
