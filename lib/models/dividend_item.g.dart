// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dividend_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DividendItem _$DividendItemFromJson(Map<String, dynamic> json) => DividendItem(
      DateTime.parse(json['created_at'] as String),
      json['id'] as String,
      json['owner_id'] as String,
      json['depot_id'] as String,
      json['depot_item_id'] as String,
      (json['amount'] as num).toDouble(),
      DateTime.parse(json['booked_at'] as String),
    );

Map<String, dynamic> _$DividendItemToJson(DividendItem instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'id': instance.id,
      'owner_id': instance.ownerId,
      'depot_id': instance.depotId,
      'depot_item_id': instance.depotItemId,
      'amount': instance.amount,
      'booked_at': instance.bookedAt.toIso8601String(),
    };
