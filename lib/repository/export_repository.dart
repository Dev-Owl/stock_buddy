import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_buddy/models/create_export_record.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/models/dividend_item.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/depot_line_repository.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/repository/dividend_repoistory.dart';
import 'package:stock_buddy/utils/duplicate_export_exception.dart';
import 'package:stock_buddy/utils/ing_diba_export_reader.dart';
import 'package:uuid/uuid.dart';

typedef UserActionNeededCallback<T> = Future<T> Function();

class ExportRepositories extends BaseRepository {
  ExportRepositories(super.backend);

  Future<List<ExportRecord>> getAllExportsForDept(String depotId) async {
    final queryParameter = {
      'include_docs': 'true',
    };

    queryParameter["keys"] = '%5B"$depotId"%5D';

    return backend.requestWithConverter(
        backend.get(
            "stockbuddy/_partition/depotExport/_design/depot/_view/exports",
            queryParameter), (data) {
      var result = <ExportRecord>[];
      if (data["rows"] != null) {
        for (var item in data["rows"]) {
          result.add(ExportRecord.fromJson(item["doc"]));
        }
      }
      return result;
    });
  }

  Future<bool> doesExportForDepotExists(
      String depotId, DateTime exportTime) async {
    final queryParameter = {
      'reduce': 'true',
      'group': 'true',
    };
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");
    queryParameter["keys"] =
        '[["$depotId","${dateFormat.format(exportTime)}"]]';
    return backend.requestWithConverter(
        backend.get(
            "stockbuddy/_partition/depotExport/_design/depot/_view/exportTime",
            queryParameter), (data) {
      var result = false;
      if (data["rows"] != null) {
        data["rows"].length > 0 ? result = true : result = false;
      }
      return result;
    });
  }

  Future<int> importNewData(
    String pathToExportFile,
    UserActionNeededCallback<String> missingRepoNameQuestion,
    UserActionNeededCallback<String> selectRepoForDividends,
  ) async {
    final reader = ExportReader();

    if (await reader.isDepotExport(pathToExportFile)) {
      final result = await _importDepotFile(
        pathToExportFile,
        missingRepoNameQuestion,
      );
      return result == null ? 0 : 1;
    } else {
      return await _importRevenueFile(
        pathToExportFile,
        selectRepoForDividends,
      );
    }
  }

  Future<int> _importRevenueFile(
    String pathToExportFile,
    UserActionNeededCallback<String> selectRepoForDividends,
  ) async {
    final reader = ExportReader();
    final revenue = await reader.paresRevenueFile(pathToExportFile);
    if (revenue == null) return 0;
    final selectedDepot = await selectRepoForDividends();
    if (selectedDepot == "") return 0;
    //Map items and create lines for the dividends
    final depotLineRepo = DepotLineRepository(backend);
    final allLineItems = await depotLineRepo.allItemsByDepotId(selectedDepot);
    //Get min&max date for revenue
    revenue.items.sort(
      (a, b) => a.bookingDate.compareTo(b.bookingDate),
    );
    final oldestRecord = revenue.items.first;
    final newestRecord = revenue.items.last;
    //Get all dividend records in the range
    final dividendRepo = DividendRepository(backend);
    final allKnownRecords = await dividendRepo.getAllDividendsBetween(
        selectedDepot, oldestRecord.bookingDate, newestRecord.bookingDate);
    final addList = <DividendItem>[];
    final ownerId = ""; // TODO FIX
    /*
        await backend.runAuthenticatedRequest<String>((client) async {
      final result = await client.rpc("current_userid").select();
      return result.toString();
    });
    */
    for (final line in revenue.items) {
      final refText = line.referenceText.toLowerCase();
      if (refText.contains('dividende') && refText.contains('isin')) {
        final isin = line.referenceText
            .substring(refText.indexOf('isin') + 4)
            .trim()
            .substring(0, 12);
        debugPrint(isin);
        final depotLineItem = allLineItems
            .where(
                (element) => element.isin.toLowerCase() == isin.toLowerCase())
            .firstOrNull;
        if (depotLineItem == null) continue;
        // Check if depotline and date already exists, if not import
        if (allKnownRecords.any((element) =>
            element.depotItemId == depotLineItem.id &&
            element.bookedAt == line.bookingDate &&
            element.amount == line.amount)) continue;

        // We know its part of the depot, and not yet imported
        //TODO FIX
        /*addList.add(
          DividendItem(
            DateTime.now(),
            const Uuid().v4(),
            ownerId,
            selectedDepot,
            depotLineItem.id,
            line.amount,
            line.bookingDate,
          ),
        );*/
      }
    }
    if (addList.isNotEmpty) {
      await dividendRepo.import(addList);
    }
    return addList.length;
  }

  Future<ExportRecord?> _importDepotFile(
    String pathToExportFile,
    UserActionNeededCallback<String> missingRepoNameQuestion,
  ) async {
    final reader = ExportReader();
    final result = await reader.parseDepotExportFile(pathToExportFile);
    final depotRepo = DepotRepository(backend);
    var depoID = await depotRepo.getRepositoryIdByNumber(result.depotNumber);

    if (depoID == null) {
      var newDepotName = await missingRepoNameQuestion();
      if (newDepotName.isEmpty) {
        newDepotName = result.customerName;
      }
      final depotRepo = DepotRepository(backend);
      depoID =
          (await depotRepo.createNewDepot(newDepotName, result.depotNumber)).id;
    }
    if (await doesExportForDepotExists(depoID, result.exportDate)) {
      throw DuplicateExportException();
    }
    final totalWinLoss = result.lineItems
        .fold<double>(0, (currentValue, e) => currentValue + e.currentWinLoss);

    final totalInvest = result.lineItems.fold<double>(
        0, (currentValue, e) => currentValue + e.totalPurchasePrice);

    final percentageTotalWinLoss = (totalWinLoss / totalInvest) * 100;

    final newExport = "depotExport:${Uuid().v4()}";
    //Ensure we have depot line item for all
    final isinList = result.lineItems.map((e) => e.isin).toList();
    // Get all line items currently in depot
    final depotIsinList = await backend.requestWithConverter(
        backend.get(
          "stockbuddy/_partition/depotItem/_design/depot/_view/itemIsin",
          {"keys": '["$depoID"]'},
        ), (r) {
      var result = <String, String>{};
      if (r["rows"] != null) {
        for (var item in r["rows"]) {
          result[item["value"][0].toString()] = item["value"][1].toString();
        }
      }
      return result;
    });

    isinList.removeWhere((isin) => depotIsinList.containsKey(isin));
    //All items in here are missing a record until now and need to be created
    for (var isin in isinList) {
      final exportItem =
          result.lineItems.firstWhere((element) => element.isin == isin);
      final newDepotItem = DepotItem(
        active: true,
        createdAt: DateTime.now(),
        isin: isin,
        lastTotalValue: exportItem.currentTotalValue,
        depotId: depoID,
        lastWinLoss: exportItem.currentWinLoss,
        lastWinLossPercent: exportItem.currentWindLossPercent,
        name: exportItem.name,
        totalDividends: 0,
        note: "",
        tags: [],
        id: "depotItem:${Uuid().v4()}",
      );
      depotIsinList[isin] = newDepotItem.id; // ensure new items are tracked
      await backend.requestWithConverter(
          backend.put("stockbuddy/${newDepotItem.id}", newDepotItem.toJson()),
          (r) {
        newDepotItem.rev = r["rev"];
      });
    }
    // Update the export record with line items
    final exportRecord = ExportRecord(
      result.exportDate,
      result.customerName,
      result.depotNumber,
      DateTime.now(),
      newExport,
      totalWinLoss,
      percentageTotalWinLoss,
      depoID,
      null,
      totalInvest,
      [],
    );
    exportRecord.lineItems = result.lineItems
        .map((e) => e.toCreateDto(depotIsinList[e.isin]!))
        .toList();

    await backend.requestWithConverter(
        backend.put("stockbuddy/$newExport", exportRecord.toJson()), (r) {
      exportRecord.rev = r["rev"];
    });
    //TODO Update the existing line item with the new export details
    final listOfUpdatedIsins = result.lineItems.map((e) => e.isin).toList();
    // Get all line items currently in depot
    // Update the data for the line items according to the value in result.lineItems

    throw UnimplementedError();
  }

  Future<bool> deleteExport(String exportID, String rev) async {
    return delete(exportID, rev);
  }
}
