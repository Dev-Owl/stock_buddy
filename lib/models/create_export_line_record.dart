import 'package:json_annotation/json_annotation.dart';
part 'create_export_line_record.g.dart';

@JsonSerializable()
class CreateExportLine {
  @JsonKey(name: 'export_id')
  final String exportId;

  final String isin;

  final String name;

  final double amount;

  @JsonKey(name: 'depot_item')
  final String depotItem;

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

  CreateExportLine(
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
    this.depotItem,
  );

  factory CreateExportLine.fromJson(Map<String, dynamic> json) =>
      _$CreateExportLineFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExportLineToJson(this);
}
