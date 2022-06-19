// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_depot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataDepot _$DataDepotFromJson(Map<String, dynamic> json) => DataDepot(
      json['name'] as String,
      json['number'] as String,
      DateTime.parse(json['created_at'] as String),
      json['id'] as String,
      json['owner_id'] as String,
      json['totalexports'] as int? ?? 0,
      (json['totalgainloss'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DataDepotToJson(DataDepot instance) {
  final val = <String, dynamic>{
    'created_at': instance.createdAt.toIso8601String(),
    'id': instance.id,
    'owner_id': instance.ownerId,
    'name': instance.name,
    'number': instance.number,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('totalexports', DataDepot.toNull(instance.totalExports));
  writeNotNull('totalgainloss', DataDepot.toNull(instance.totalGainLoss));
  return val;
}
