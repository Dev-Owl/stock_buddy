import 'package:stock_buddy/models/create_export_line_record.dart';

class DepotLineItem {
  final String isin;
  final String name;
  final double amount;
  final String amountType;
  final double singlePurchasePrice;
  final String currency;
  final double totalPurchasePrice;
  final double currentValue;
  final String currentValueTime;
  final String marketName;
  final double currentTotalValue;
  final double currentWinLoss;
  final double currentWindLossPercent;

  DepotLineItem(
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
  );

  CreateExportLine toCreateDto(String exportId, String depotLineItemId) {
    return CreateExportLine(
        exportId,
        isin,
        name,
        amount,
        amountType,
        singlePurchasePrice,
        currency,
        totalPurchasePrice,
        currentValue,
        currentValueTime,
        marketName,
        currentTotalValue,
        currentWinLoss,
        currentWindLossPercent,
        depotLineItemId);
  }
}
