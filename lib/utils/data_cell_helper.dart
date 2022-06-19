import 'package:flutter/material.dart';
import 'package:stock_buddy/utils/text_helper.dart';

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
    return DataCell(
      TextHelper.number(
        amount,
        decoration: decoration,
        colorCode: colorCode,
        context: context,
        decimalPlaces: decimalPlaces,
      ),
    );
  }
}
