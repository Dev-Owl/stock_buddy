import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stock_buddy/models/report_chart_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:stock_buddy/utils/chart_helper.dart';

class CurrentInvestedChar extends StatelessWidget {
  final List<ReportChartModel> chartData;
  const CurrentInvestedChar({required this.chartData, Key? key})
      : super(key: key);

  List<charts.Series<ReportChartModel, DateTime>> _createChartingDate() {
    return [
      charts.Series<ReportChartModel, DateTime>(
        id: 'Currentvalue',
        colorFn: (m, i) {
          var up = false;
          if (i != null) {
            final prevIndex = max(0, i - 1);
            up = chartData[prevIndex].totalInvest >= m.totalInvest;
          }

          return up
              ? charts.MaterialPalette.green.shadeDefault
              : charts.MaterialPalette.red.shadeDefault;
        },
        domainFn: (r, _) => DateTime(
          r.exportTime.year,
          r.exportTime.month,
          r.exportTime.day,
        ),
        measureFn: (r, _) => r.totalInvest,
        data: chartData,
        displayName: 'Current value',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      _createChartingDate(),
      animate: true,
      behaviors: [
        charts.ChartTitle(
          'Invested',
          behaviorPosition: charts.BehaviorPosition.top,
          titleOutsideJustification: charts.OutsideJustification.middle,
          titleStyleSpec: const charts.TextStyleSpec(
            color: charts.MaterialPalette.white,
          ),
        ),
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: const charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.MaterialPalette.white,
          ),
        ),
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          zeroBound: false,
          dataIsInWholeNumbers: false,
        ),
        tickFormatterSpec: currencyNumberFormater,
      ),
      domainAxis: const charts.DateTimeAxisSpec(
        showAxisLine: false,
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.MaterialPalette.white,
          ),
        ),
      ),
      defaultRenderer: charts.LineRendererConfig(
        includePoints: true,
      ),
    );
  }
}
