import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:stock_buddy/models/dividend_item.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class DividendsEarendChart extends StatelessWidget {
  final List<DividendItem> chartData;

  const DividendsEarendChart({required this.chartData, super.key});

  List<charts.Series<MapEntry<int, double>, String>> _createChartingDate() {
    final gainByMonth = chartData
        .groupFoldBy<int, double>((element) => element.bookedAt.month,
            (previous, element) => (previous ?? 0) + element.amount)
        .entries
        .toList();
    gainByMonth.sort((a, b) => a.key.compareTo(b.key));

    return [
      charts.Series<MapEntry<int, double>, String>(
        id: 'id',
        colorFn: (m, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (r, _) => "${r.key}",
        measureFn: (r, _) => r.value,
        data: gainByMonth,
        displayName: 'Current value',
        labelAccessorFn: (v, _) => '${v.value.toStringAsFixed(2).toString()}€',
        insideLabelStyleAccessorFn: (sales, _) {
          return const charts.TextStyleSpec(
              color: charts.MaterialPalette.black);
        },
        outsideLabelStyleAccessorFn: (sales, _) {
          return const charts.TextStyleSpec(
              color: charts.MaterialPalette.black);
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _createChartingDate(),
      animate: true,
      behaviors: [
        charts.ChartTitle(
          'Dividends by month total ${chartData.fold<double>(0, (previousValue, element) => previousValue + element.amount).toStringAsFixed(2)}€',
          behaviorPosition: charts.BehaviorPosition.top,
          titleOutsideJustification: charts.OutsideJustification.middle,
          titleStyleSpec: const charts.TextStyleSpec(
            color: charts.MaterialPalette.white,
          ),
        ),
      ],
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec:
            charts.BasicNumericTickProviderSpec(desiredTickCount: 10),
      ),
    );
  }
}
