import 'package:flutter/material.dart';
import 'package:stock_buddy/models/report_chart_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:stock_buddy/utils/chart_helper.dart';

class CurrentValueChar extends StatelessWidget {
  final List<ReportChartModel> chartData;
  const CurrentValueChar({required this.chartData, super.key});

  List<charts.Series<ReportChartModel, DateTime>> _createChartingDate() {
    return [
      charts.Series<ReportChartModel, DateTime>(
        id: 'Currentvalue',
        colorFn: (m, __) => m.winLoss < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        domainFn: (r, _) => DateTime(
          r.exportTime.year,
          r.exportTime.month,
          r.exportTime.day,
        ),
        measureFn: (r, _) => r.winLoss,
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
          'Current value',
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
