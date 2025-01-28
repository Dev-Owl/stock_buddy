import 'package:json_annotation/json_annotation.dart';

part 'export_line_item.g.dart';

@JsonSerializable()
class ExportLineItem {
  String isin;
  String name;
  double amount;
  String amountType;
  double singlePurchasePrice;
  String currency;
  double totalPurchasePrice;
  double currentValue;
  String marketName;
  double currentTotalValue;
  double currentWinLoss;
  double currentWindLossPercent;
  String depotItemId;
  List<String> tags =
      []; //TODO This has to be set somehow later, its not part of the model

  ExportLineItem(
    this.isin,
    this.name,
    this.amount,
    this.amountType,
    this.singlePurchasePrice,
    this.currency,
    this.totalPurchasePrice,
    this.currentValue,
    this.marketName,
    this.currentTotalValue,
    this.currentWinLoss,
    this.currentWindLossPercent,
    this.depotItemId,
  );

  factory ExportLineItem.fromJson(Map<String, dynamic> json) =>
      _$ExportLineItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExportLineItemToJson(this);
}
