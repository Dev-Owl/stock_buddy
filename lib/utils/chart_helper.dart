import 'package:intl/intl.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

final currencyNumberFormater =
    charts.BasicNumericTickFormatterSpec.fromNumberFormat(
  NumberFormat.currency(
    decimalDigits: 2,
    locale: 'de',
    name: 'EUR',
  ),
);
