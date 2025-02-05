// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_depot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataDepot _$DataDepotFromJson(Map<String, dynamic> json) => DataDepot(
      json['name'] as String,
      json['number'] as String,
      dateFromJson(json['createdAt'] as String),
      json['_id'] as String,
      json['_rev'] as String?,
      (json['totalExports'] as num).toInt(),
      (json['totalGainLoss'] as num).toDouble(),
      (json['totalGainLossPercent'] as num).toDouble(),
      json['notes'] as String?,
      nullableDateFromJson(json['lastExportTime'] as String?),
    );

Map<String, dynamic> _$DataDepotToJson(DataDepot instance) => <String, dynamic>{
      'createdAt': dateToJson(instance.createdAt),
      '_id': instance.id,
      if (instance.rev case final value?) '_rev': value,
      'notes': instance.notes,
      'name': instance.name,
      'number': instance.number,
      'totalExports': instance.totalExports,
      'totalGainLoss': instance.totalGainLoss,
      'totalGainLossPercent': instance.totalGainLossPercent,
      'lastExportTime': nullableDateToJson(instance.lastExportTime),
    };
