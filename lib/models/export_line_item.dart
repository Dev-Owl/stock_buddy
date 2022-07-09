import 'package:json_annotation/json_annotation.dart';
import 'package:stock_buddy/models/base_db_model.dart';

part 'export_line_item.g.dart';

@JsonSerializable()
class ExportLineItem extends BaseDatabaseModel {
  @JsonKey(name: 'export_id')
  final String exportId;

  final String isin;

  final String name;

  final double amount;

  @JsonKey(name: 'amount_type')
  final String amountType;

  @JsonKey(name: 'single_purchase_price')
  final double singlePurchasePrice;

  final String currency;

  @JsonKey(name: 'total_purchase_price')
  final double totalPurchasePrice;

  @JsonKey(name: 'current_value')
  final double currentValue;

  @JsonKey(name: 'export_time')
  final String currentValueTime;

  @JsonKey(name: 'market_name')
  final String marketName;

  @JsonKey(name: 'current_total_value')
  final double currentTotalValue;

  @JsonKey(name: 'current_win_loss')
  final double currentWinLoss;

  @JsonKey(name: 'current_win_loss_percent')
  final double currentWindLossPercent;

  final List<String>? tags;

  ExportLineItem(
    this.exportId,
    this.isin,
    this.name,
    this.amount,
    this.amountType,
    this.singlePurchasePrice,
    this.currency,
    this.totalPurchasePrice,
    this.currentValue,
    this.currentValueTime,
    this.marketName,
    this.currentTotalValue,
    this.currentWinLoss,
    this.currentWindLossPercent,
    DateTime createdAt,
    String id,
    String ownerId,
    this.tags,
  ) : super(createdAt, id, ownerId);

  factory ExportLineItem.fromJson(Map<String, dynamic> json) =>
      _$ExportLineItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExportLineItemToJson(this);
}
