import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:intl/intl.dart';

final currencyNumberFormater =
    charts.BasicNumericTickFormatterSpec.fromNumberFormat(
  NumberFormat.currency(
    decimalDigits: 2,
    locale: 'de',
    name: 'EUR',
  ),
);
