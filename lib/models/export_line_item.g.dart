// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_line_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportLineItem _$ExportLineItemFromJson(Map<String, dynamic> json) =>
    ExportLineItem(
      json['isin'] as String,
      json['name'] as String,
      (json['amount'] as num).toDouble(),
      json['amountType'] as String,
      (json['singlePurchasePrice'] as num).toDouble(),
      json['currency'] as String,
      (json['totalPurchasePrice'] as num).toDouble(),
      (json['currentValue'] as num).toDouble(),
      json['marketName'] as String,
      (json['currentTotalValue'] as num).toDouble(),
      (json['currentWinLoss'] as num).toDouble(),
      (json['currentWindLossPercent'] as num).toDouble(),
      json['depotItemId'] as String,
    );

Map<String, dynamic> _$ExportLineItemToJson(ExportLineItem instance) =>
    <String, dynamic>{
      'isin': instance.isin,
      'name': instance.name,
      'amount': instance.amount,
      'amountType': instance.amountType,
      'singlePurchasePrice': instance.singlePurchasePrice,
      'currency': instance.currency,
      'totalPurchasePrice': instance.totalPurchasePrice,
      'currentValue': instance.currentValue,
      'marketName': instance.marketName,
      'currentTotalValue': instance.currentTotalValue,
      'currentWinLoss': instance.currentWinLoss,
      'currentWindLossPercent': instance.currentWindLossPercent,
      'depotItemId': instance.depotItemId,
    };
