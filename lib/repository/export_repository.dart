import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_buddy/models/create_export_record.dart';
import 'package:stock_buddy/models/dividend_item.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/depot_line_repository.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/repository/dividend_repoistory.dart';
import 'package:stock_buddy/utils/duplicate_export_exception.dart';
import 'package:stock_buddy/utils/ing_diba_export_reader.dart';

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
    queryParameter["keys"] = backend
        .encodePath('[["depot:$depotId","${dateFormat.format(exportTime)}"]]');
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

    final creationModel = CreateExportRecord(
      result.exportDate,
      result.customerName,
      result.depotNumber,
      totalWinLoss,
      percentageTotalWinLoss,
      depoID,
      totalInvest,
    );
    throw UnimplementedError();
    /*
    return await backend.runAuthenticatedRequest<ExportRecord?>((client) async {
      final response = await client
          .from('depot_exports')
          .insert(
            creationModel.toJson(),
          )
          .select()
          .withConverter(
            (responseData) => ModelConverter.first(
              responseData,
              (singleElement) => ExportRecord.fromJson(singleElement),
            ),
          );

      final parentId = response.id;
      //Ensure we have depot line item for all
      final isinList = result.lineItems.map((e) => e.isin).toList();
      final depotItemsResponse = await client
          .from('depot_items')
          .select('id,isin')
          .eq('depot_id', depoID!)
          .withConverter((data) => ModelConverter.modelList(
              data,
              (singleElement) => MapEntry(singleElement['isin'].toString(),
                  singleElement['id'].toString())));

      isinList.removeWhere((isin) =>
          depotItemsResponse.any((isinMapping) => isinMapping.key == isin));
      Map<String, String> isinDepotItemMapping = {};
      isinDepotItemMapping.addEntries(depotItemsResponse);
      if (isinList.isNotEmpty) {
        //All items in here are missing a record until now
        final creatioResponse = await client
            .from('depot_items')
            .insert(isinList
                .map(
                  (isin) => CreateDepotItem(
                    depoID!,
                    isin,
                    result.lineItems
                        .firstWhere((element) => element.isin == isin)
                        .name,
                  ).toJson(),
                )
                .toList())
            .select()
            .withConverter((data) => ModelConverter.modelList(
                data, (singleElement) => DepotItem.fromJson(singleElement)));
        for (var element in creatioResponse) {
          isinDepotItemMapping[element.isin] = element.id;
        }
      }

      try {
        final dataToInsert = result.lineItems
            .map(
              (e) => e
                  .toCreateDto(
                    parentId,
                    isinDepotItemMapping[e.isin]!,
                  )
                  .toJson(),
            )
            .toList();
        await client.from('line_items').insert(dataToInsert);
      } catch (e) {
        debugPrint(e.toString());
      }

      //Update the stats for depot items
      final listOfUpdatedIsins = result.lineItems.map((e) => e.isin).toList();
      final updateRequest = await client.rpc(
        'updatedepotitems',
        params: {
          'isinfilter': listOfUpdatedIsins,
        },
      );
      handleNoValueResponse(updateRequest);

      return response;
    });
    */
  }

  Future<bool> deleteExport(String exportID, String rev) async {
    return delete(exportID, rev);
  }
}
