// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deopt_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepotItem _$DepotItemFromJson(Map<String, dynamic> json) => DepotItem(
      isin: json['isin'] as String,
      name: json['name'] as String,
      depotId: json['depotId'] as String,
      lastTotalValue: (json['lastTotalValue'] as num).toDouble(),
      lastWinLoss: (json['lastWinLoss'] as num).toDouble(),
      lastWinLossPercent: (json['lastWinLossPercent'] as num).toDouble(),
      active: json['active'] as bool,
      totalDividends: (json['totalDividends'] as num).toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      note: json['note'] as String?,
      id: json['_id'] as String,
      rev: json['_rev'] as String?,
      createdAt: dateFromJson(json['createdAt'] as String),
    );

Map<String, dynamic> _$DepotItemToJson(DepotItem instance) => <String, dynamic>{
      'createdAt': dateToJson(instance.createdAt),
      '_id': instance.id,
      if (instance.rev case final value?) '_rev': value,
      'tags': instance.tags,
      'isin': instance.isin,
      'note': instance.note,
      'name': instance.name,
      'depotId': instance.depotId,
      'lastTotalValue': instance.lastTotalValue,
      'lastWinLoss': instance.lastWinLoss,
      'lastWinLossPercent': instance.lastWinLossPercent,
      'active': instance.active,
      'totalDividends': instance.totalDividends,
    };
