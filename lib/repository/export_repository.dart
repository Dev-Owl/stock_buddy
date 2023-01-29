import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/models/create_depot_item.dart';
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
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:uuid/uuid.dart';

typedef UserActionNeededCallback<T> = Future<T> Function();

class ExportRepositories extends BaseRepository {
  ExportRepositories(super.backend);

  Future<List<ExportRecord>> getAllExportsForDept(String depotId) async {
    return await backend
        .runAuthenticatedRequest<List<ExportRecord>>((client) async {
      final response = await client
          .from('depot_exports')
          .select()
          .eq('depot_id', depotId)
          .order(
            'export_time',
            ascending: false,
          )
          .withConverter<List<ExportRecord>>(
            (data) => ModelConverter.modelList(
              data,
              (singleElement) => ExportRecord.fromJson(
                singleElement,
              ),
            ),
          );
      return response;
    });
  }

  Future<bool> doesExportForDepotExists(
      String depotId, DateTime exportTime) async {
    return await backend.runAuthenticatedRequest<bool>((client) async {
      final response = await client
          .from('depot_exports')
          .select(
              'id',
              const FetchOptions(
                count: CountOption.exact,
              ))
          .eq('depot_id', depotId)
          .eq('export_time', exportTime);
      handleNoValueResponse(response);
      return (response.count ?? 0) == 1;
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
    final ownerId =
        await backend.runAuthenticatedRequest<String>((client) async {
      final result = await client.rpc("current_userid").select();
      return result.toString();
    });
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
        addList.add(
          DividendItem(
            DateTime.now(),
            const Uuid().v4(),
            ownerId,
            selectedDepot,
            depotLineItem.id,
            line.amount,
            line.bookingDate,
          ),
        );
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
          .eq('depot_id', depoID)
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
                  ),
                )
                .toList())
            .select()
            .withConverter((data) => ModelConverter.modelList(
                data, (singleElement) => DepotItem.fromJson(singleElement)));
        for (var element in creatioResponse) {
          isinDepotItemMapping[element.isin] = element.id;
        }
      }

      await client.from('line_items').insert(
            result.lineItems
                .map(
                  (e) => e.toCreateDto(
                    parentId,
                    isinDepotItemMapping[e.isin]!,
                  ),
                )
                .toList(),
          );
      //Update the stats for depot items
      final listOfUpdatedIsins = result.lineItems.map((e) => e.isin).toList();
      final updateRequest = await client.rpc('updatedepotitems',
          params: {
            'isinfilter': listOfUpdatedIsins,
          },
          options: const FetchOptions(
            forceResponse: true,
          ));
      handleNoValueResponse(updateRequest);

      return response;
    });
  }

  Future<bool> deleteExport(String exportID) async {
    return await backend.runAuthenticatedRequest<bool>((client) async {
      try {
        final result = await client
            .from('depot_exports')
            .delete()
            .match({'id': exportID}).select();
        handleNoValueResponse(result);
        return true;
      } catch (ex) {
        return false;
      }
    });
  }
}
