// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_chart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportChartModel _$ReportChartModelFromJson(Map<String, dynamic> json) =>
    ReportChartModel(
      DateTime.parse(json['export_time'] as String),
      (json['win_loss_amount'] as num).toDouble(),
      (json['totalinvest'] as num).toDouble(),
    );

Map<String, dynamic> _$ReportChartModelToJson(ReportChartModel instance) =>
    <String, dynamic>{
      'export_time': instance.exportTime.toIso8601String(),
      'win_loss_amount': instance.winLoss,
      'totalinvest': instance.totalInvest,
    };
