import 'package:json_annotation/json_annotation.dart';

part 'report_chart_model.g.dart';

@JsonSerializable()
class ReportChartModel {
  @JsonKey(name: 'export_time')
  final DateTime exportTime;
  @JsonKey(name: 'win_loss_amount')
  final double winLoss;
  @JsonKey(name: 'totalinvest')
  final double totalInvest;

  ReportChartModel(this.exportTime, this.winLoss, this.totalInvest);

  factory ReportChartModel.fromJson(Map<String, dynamic> json) =>
      _$ReportChartModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportChartModelToJson(this);
}
