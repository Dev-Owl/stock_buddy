import 'package:stock_buddy/models/export_line_item.dart';
import 'package:stock_buddy/models/report_chart_model.dart';

class ReportScreenModel {
  final List<ReportChartModel> valueChart;
  final int totalPositions;
  final List<ExportLineItem> lastItems;
  ReportScreenModel(
    this.valueChart,
    this.totalPositions,
    this.lastItems,
  );
}
