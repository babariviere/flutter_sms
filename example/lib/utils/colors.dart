import 'package:flutter/material.dart';

class ContactColor {
  static List<Color> _colors = [
    new Color(0xFFDB4437),
    new Color(0xFFE91E63),
    new Color(0xFF9C27B0),
    new Color(0xFF673AB7),
    new Color(0xFF3F51B5),
    new Color(0xFF4285F4),
    new Color(0xFF039BE5),
    new Color(0xFF0097A7),
    new Color(0xFF009688),
    new Color(0xFF0F9D58),
    new Color(0xFF689F38),
    new Color(0xFFEF6C00),
    new Color(0xFFFF5722),
    new Color(0xFF757575),
  ];

  static List<Color> get allColors {
    return _colors;
  }

  static Color getColor(String contactId) {
    final int color = (contactId.hashCode % ContactColor.allColors.length);
    return ContactColor.allColors.elementAt(color);
  }
}
