import 'package:flutter/material.dart';
import 'package:stock_buddy/models/export_line_item.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class PercentagePieChart extends StatelessWidget {
  final List<ExportLineItem> items;

  const PercentagePieChart({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return charts.PieChart<String>(
      _createData(),
      animate: true,
      defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [
        charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.auto)
      ]),
    );
  }

  List<charts.Series<ExportLineItem, String>> _createData() {
    final total = items.fold<double>(0,
        (previousValue, element) => previousValue + element.totalPurchasePrice);

    return [
      charts.Series<ExportLineItem, String>(
        id: 'Distribution',
        domainFn: (ExportLineItem e, _) => e.isin,
        measureFn: (ExportLineItem e, _) =>
            (e.totalPurchasePrice / total) * 100,
        data: items,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (ExportLineItem row, _) =>
            '${row.isin}:${((row.totalPurchasePrice / total) * 100).toStringAsFixed(0)}%',
      )
    ];
  }
}
