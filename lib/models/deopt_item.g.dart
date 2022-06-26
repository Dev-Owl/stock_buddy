// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deopt_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepotItem _$DepotItemFromJson(Map<String, dynamic> json) => DepotItem(
      DateTime.parse(json['created_at'] as String),
      json['id'] as String,
      json['owner_id'] as String,
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['isin'] as String,
      json['depot_id'] as String,
      json['note'] as String?,
      json['name'] as String,
    );

Map<String, dynamic> _$DepotItemToJson(DepotItem instance) => <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'id': instance.id,
      'owner_id': instance.ownerId,
      'tags': instance.tags,
      'isin': instance.isin,
      'note': instance.note,
      'name': instance.name,
      'depot_id': instance.depotId,
    };
