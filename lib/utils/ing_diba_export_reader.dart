import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:intl/intl.dart';
import 'package:stock_buddy/models/depot.dart';
import 'package:stock_buddy/models/depot_line_item.dart';
import 'package:stock_buddy/models/revenue_export_models.dart';

const int colISIN = 0;
const int colName = 1;
const int colAmount = 2;
const int colAmountType = 3;
const int colPurchasePrice = 4;
const int colCurrency = 5;
const int colTotalPurchasePrice = 6;
const int colCurrentPrice = 8;
const int colTime = 10;
const int colMarket = 11;
const int colTotalCurrentPrice = 12;
const int colWinLoss = 14;
const int colWinLossPercent = 16;

class ExportReader {
  ExportReader();

  Future<bool> isDepotExport(String pathToCSV) async {
    assert(pathToCSV.isNotEmpty);
    final exportFile = File(pathToCSV);
    assert(await exportFile.exists());
    final content =
        await exportFile.readAsString(encoding: const Latin1Codec());
    assert(content.isNotEmpty);
    return content.startsWith('Depotübersicht');
  }

  Future<RevenueExport?> paresRevenueFile(String pathToCSV) async {
    const int bookingData = 0;
    const int client = 2;
    const int bookingText = 3;
    const int reference = 4;
    const int saldo = 5;
    const int amount = 7;
    assert(pathToCSV.isNotEmpty);
    final exportFile = File(pathToCSV);
    assert(await exportFile.exists());
    final content =
        await exportFile.readAsString(encoding: const Latin1Codec());
    assert(content.isNotEmpty);
    //Setup csv config
    const csvConfig = FirstOccurrenceSettingsDetector(
      fieldDelimiters: [";"],
    );
    const csvReader = CsvToListConverter(
      csvSettingsDetector: csvConfig,
    );
    final numberFormat = NumberFormat.decimalPattern('de');

    //The export of the ING contains multiple CSV tables
    final allLine = LineSplitter.split(content);
    var cleanedFirstLine = allLine.first
        .replaceAll(
          RegExp("[^0-9.: ]"),
          "",
        )
        .trim();
    if (cleanedFirstLine.length > 16) {
      cleanedFirstLine =
          cleanedFirstLine.substring(cleanedFirstLine.length - 16);
    }

    final dateFormat = DateFormat("dd.MM.yyyy HH:mm");
    final lineDateFormat = DateFormat("dd.MM.yyyy");
    final DateTime exportDate = dateFormat.parse(cleanedFirstLine);
    final accountNumber = allLine.skip(2).take(1).first.split(";").last;

    final allLineItemsRaw =
        allLine.skip(14).take(allLine.length - 15).toList().join("\n");
    final allLineItemsCsv = csvReader.convert(allLineItemsRaw, eol: "\n");
    final items = <RevenueItem>[];
    for (var row in allLineItemsCsv) {
      items.add(
        RevenueItem(
          lineDateFormat.parse(row[bookingData].toString()),
          row[client].toString(),
          row[bookingText].toString(),
          row[reference].toString(),
          numberFormat.parseDouble(row[saldo].toString()),
          numberFormat.parseDouble(row[amount].toString()),
          row.last.toString(),
        ),
      );
    }
    return RevenueExport(accountNumber, exportDate, items);
  }

  Future<Depot> parseDepotExportFile(String pathToCSV) async {
    assert(pathToCSV.isNotEmpty);
    final exportFile = File(pathToCSV);
    assert(await exportFile.exists());
    final content =
        await exportFile.readAsString(encoding: const Latin1Codec());
    assert(content.isNotEmpty);
    //Setup csv config
    const csvConfig = FirstOccurrenceSettingsDetector(
      fieldDelimiters: [";"],
    );
    const csvReader = CsvToListConverter(
      csvSettingsDetector: csvConfig,
    );
    final numberFormat = NumberFormat.decimalPattern('de');

    //The export of the ING contains multiple CSV tables
    final allLine = LineSplitter.split(content);
    //First line has the date of the export
    final cleanedFirstLine = allLine.first
        .replaceAll(
          RegExp("[^0-9.: ]"),
          "",
        )
        .trim();
    final dateFormat = DateFormat("dd.MM.yyyy HH:mm");
    final DateTime exportDate = dateFormat.parse(cleanedFirstLine);

    //Second has the customer name
    final secondLine = allLine.skip(1).take(1).first;
    final parsedSecondLine = csvReader
        .convert<String>(
          secondLine,
          shouldParseNumbers: false,
        )
        .first;
    final customerName = parsedSecondLine.last;

    //Line 4 contains the depot number
    final depotNumberLine = allLine.skip(3).take(1).first;
    final parsedDepotNumberLine = csvReader
        .convert<String>(
          depotNumberLine,
          shouldParseNumbers: false,
        )
        .first;
    final depotNumber = parsedDepotNumberLine.last;

    //Now all line items are comming, skip the header row and the last summary row
    final allLineItemsRaw =
        allLine.skip(6).take(allLine.length - 7).toList().join("\n");
    final allLineItemsCsv = csvReader.convert(allLineItemsRaw, eol: "\n");
    final List<DepotLineItem> lineItems = [];
    for (var item in allLineItemsCsv) {
      lineItems.add(
        DepotLineItem(
          item[colISIN],
          item[colName],
          numberFormat.parseDouble(item[colAmount].toString()),
          item[colAmountType],
          numberFormat.parseDouble(item[colPurchasePrice].toString()),
          item[colCurrency],
          numberFormat.parseDouble(item[colTotalPurchasePrice].toString()),
          numberFormat.parseDouble(item[colCurrentPrice].toString()),
          item[colTime],
          item[colMarket],
          numberFormat.parseDouble(item[colTotalCurrentPrice].toString()),
          numberFormat.parseDouble(item[colWinLoss].toString()),
          numberFormat.parseDouble(
              item[colWinLossPercent].toString().replaceAll("%", "")),
        ),
      );
    }
    return Depot(exportDate, customerName, depotNumber, lineItems);
  }
}

extension DoubleHelper on NumberFormat {
  double parseDouble(String input) {
    return parse(input).toDouble();
  }
}
