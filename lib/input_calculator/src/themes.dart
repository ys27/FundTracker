import 'package:flutter/material.dart';

enum CalculatorThemes {
  curve,
  flat,
}

extension ThemesExtension on CalculatorThemes {
  BoxDecoration get panelButtonDecoration {
    switch (this) {
      case CalculatorThemes.curve:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(48)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0, -1),
              blurRadius: 4,
            )
          ],
        );
      case CalculatorThemes.flat:
        return BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0, -1),
              blurRadius: 4,
            )
          ],
        );
      default:
        return BoxDecoration(
          color: Colors.white,
        );
    }
  }

  ShapeBorder get buttonShape {
    switch (this) {
      case CalculatorThemes.curve:
        return StadiumBorder();
      case CalculatorThemes.flat:
        return RoundedRectangleBorder();
      default:
        return RoundedRectangleBorder();
    }
  }
}
