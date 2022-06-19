import 'package:flutter/material.dart';

class TextHelper {
  static Text number(
    double amount, {
    String decoration = "",
    bool colorCode = true,
    int decimalPlaces = 2,
    BuildContext? context,
  }) {
    TextStyle? style;
    if (colorCode) {
      assert(context != null);
      final isNegative = amount < 0;
      style = Theme.of(context!).textTheme.bodyMedium!.copyWith(
            color: isNegative ? Colors.redAccent : Colors.green,
          );
    }

    final formatedString =
        "${amount.toStringAsFixed(decimalPlaces)}$decoration";

    return Text(
      formatedString,
      style: style,
    );
  }
}
