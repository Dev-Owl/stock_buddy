// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportRecord _$ExportRecordFromJson(Map<String, dynamic> json) => ExportRecord(
      DateTime.parse(json['export_time'] as String),
      json['name'] as String,
      json['number'] as String,
      DateTime.parse(json['created_at'] as String),
      json['id'] as String,
      json['owner_id'] as String,
      (json['win_loss_amount'] as num).toDouble(),
      (json['win_loss_percent'] as num).toDouble(),
      json['depot_id'] as String,
      (json['total_spent'] as num).toDouble(),
    );

Map<String, dynamic> _$ExportRecordToJson(ExportRecord instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'id': instance.id,
      'owner_id': instance.ownerId,
      'export_time': instance.exportDate.toIso8601String(),
      'name': instance.customerName,
      'number': instance.depotNumber,
      'win_loss_amount': instance.winLossAmount,
      'win_loss_percent': instance.winLossPercent,
      'depot_id': instance.depotId,
      'total_spent': instance.totalValue,
    };
