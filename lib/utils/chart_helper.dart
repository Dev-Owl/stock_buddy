import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

final currencyNumberFormater =
    charts.BasicNumericTickFormatterSpec.fromNumberFormat(
  NumberFormat.currency(
    decimalDigits: 2,
    locale: 'de',
    name: 'EUR',
  ),
);
