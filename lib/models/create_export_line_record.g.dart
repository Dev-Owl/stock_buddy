// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_export_line_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExportLine _$CreateExportLineFromJson(Map<String, dynamic> json) =>
    CreateExportLine(
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
      json['depot_item'] as String,
    );

Map<String, dynamic> _$CreateExportLineToJson(CreateExportLine instance) =>
    <String, dynamic>{
      'export_id': instance.exportId,
      'isin': instance.isin,
      'name': instance.name,
      'amount': instance.amount,
      'depot_item': instance.depotItem,
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
    };
