// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_depot_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDepotItem _$CreateDepotItemFromJson(Map<String, dynamic> json) =>
    CreateDepotItem(
      json['depot_id'] as String,
      json['isin'] as String,
      json['name'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateDepotItemToJson(CreateDepotItem instance) =>
    <String, dynamic>{
      'depot_id': instance.depotId,
      'isin': instance.isin,
      'name': instance.name,
      'tags': instance.tags,
    };
