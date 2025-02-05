// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportRecord _$ExportRecordFromJson(Map<String, dynamic> json) => ExportRecord(
      dateFromJson(json['exportTime'] as String),
      json['name'] as String,
      json['number'] as String,
      dateFromJson(json['createdAt'] as String),
      json['_id'] as String,
      (json['winLossAmount'] as num).toDouble(),
      (json['winLossPercent'] as num).toDouble(),
      json['depotId'] as String,
      json['_rev'] as String?,
      (json['totalSpent'] as num).toDouble(),
      (json['lineItems'] as List<dynamic>)
          .map((e) => ExportLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExportRecordToJson(ExportRecord instance) =>
    <String, dynamic>{
      'createdAt': dateToJson(instance.createdAt),
      '_id': instance.id,
      if (instance.rev case final value?) '_rev': value,
      'exportTime': dateToJson(instance.exportTime),
      'name': instance.name,
      'number': instance.number,
      'winLossAmount': instance.winLossAmount,
      'winLossPercent': instance.winLossPercent,
      'depotId': instance.depotId,
      'totalSpent': instance.totalSpent,
      'lineItems': instance.lineItems,
    };
