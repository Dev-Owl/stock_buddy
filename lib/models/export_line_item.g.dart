// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_line_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportLineItem _$ExportLineItemFromJson(Map<String, dynamic> json) =>
    ExportLineItem(
      json['export_id'] as String,
      json['isin'] as String,
      json['name'] as String,
      (json['amount'] as num).toDouble(),
      json['amount_type'] as String,
      (json['single_purchase_price'] as num).toDouble(),
      json['currency'] as String,
      (json['total_purchase_price'] as num).toDouble(),
      (json['current_value'] as num).toDouble(),
      json['export_time'] as String,
      json['market_name'] as String,
      (json['current_total_value'] as num).toDouble(),
      (json['current_win_loss'] as num).toDouble(),
      (json['current_win_loss_percent'] as num).toDouble(),
      DateTime.parse(json['created_at'] as String),
      json['id'] as String,
      json['owner_id'] as String,
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ExportLineItemToJson(ExportLineItem instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'id': instance.id,
      'owner_id': instance.ownerId,
      'export_id': instance.exportId,
      'isin': instance.isin,
      'name': instance.name,
      'amount': instance.amount,
      'amount_type': instance.amountType,
      'single_purchase_price': instance.singlePurchasePrice,
      'currency': instance.currency,
      'total_purchase_price': instance.totalPurchasePrice,
      'current_value': instance.currentValue,
      'export_time': instance.currentValueTime,
      'market_name': instance.marketName,
      'current_total_value': instance.currentTotalValue,
      'current_win_loss': instance.currentWinLoss,
      'current_win_loss_percent': instance.currentWindLossPercent,
      'tags': instance.tags,
    };
