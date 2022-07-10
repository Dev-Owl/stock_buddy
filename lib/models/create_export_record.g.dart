// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_export_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExportRecord _$CreateExportRecordFromJson(Map<String, dynamic> json) =>
    CreateExportRecord(
      DateTime.parse(json['export_time'] as String),
      json['name'] as String,
      json['number'] as String,
      (json['win_loss_amount'] as num).toDouble(),
      (json['win_loss_percent'] as num).toDouble(),
      json['depot_id'] as String,
      (json['total_spent'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateExportRecordToJson(CreateExportRecord instance) =>
    <String, dynamic>{
      'export_time': instance.exportDate.toIso8601String(),
      'name': instance.customerName,
      'number': instance.depotNumber,
      'win_loss_amount': instance.winLossAmount,
      'win_loss_percent': instance.winLossPercent,
      'depot_id': instance.depotId,
      'total_spent': instance.totalValue,
    };
