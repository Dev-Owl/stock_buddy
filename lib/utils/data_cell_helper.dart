import 'package:flutter/material.dart';

class CellHelper {
  static DataCell textCell(
    String text, {
    TextStyle? style,
  }) {
    return DataCell(Text(
      text,
      style: style,
    ));
  }

  static DataCell number(
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

    return textCell(
      formatedString,
      style: style,
    );
  }
}
