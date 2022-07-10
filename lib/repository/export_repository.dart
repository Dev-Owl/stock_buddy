import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/create_depot_item.dart';
import 'package:stock_buddy/models/create_export_record.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/utils/duplicate_export_exception.dart';
import 'package:stock_buddy/utils/ing_diba_export_reader.dart';
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef UserActionNeededCallback<T> = Future<T> Function();

class ExportRepositories extends BaseRepository {
  Future<List<ExportRecord>> getAllExportsForDept(String depotId) async {
    final response = await supabase
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
        )
        .execute();
    return handleResponse(response, []);
  }

  Future<bool> doesExportForDepotExists(
      String depotId, DateTime exportTime) async {
    final response = await supabase
        .from('depot_exports')
        .select('id')
        .eq('depot_id', depotId)
        .eq('export_time', exportTime)
        .execute(count: CountOption.exact);
    handleNoValueResponse(response);
    return (response.count ?? 0) == 1;
  }

  Future<ExportRecord?> importNewData(
    String pathToExportFile,
    UserActionNeededCallback<String> missingRepoNameQuestion,
  ) async {
    final reader = ExportReader();

    final result = await reader.parseFile(pathToExportFile);
    final depotRepo = DepotRepository();
    var depoID = await depotRepo.getRepositoryIdByNumber(result.depotNumber);

    if (depoID == null) {
      var newDepotName = await missingRepoNameQuestion();
      if (newDepotName.isEmpty) {
        newDepotName = result.customerName;
      }
      final depotRepo = DepotRepository();
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
    final response = await supabase
        .from('depot_exports')
        .insert(
          creationModel.toJson(),
        )
        .withConverter(
          (responseData) => ModelConverter.first(
            responseData,
            (singleElement) => ExportRecord.fromJson(singleElement),
          ),
        )
        .execute();

    if (response.data != null) {
      final parentId = response.data!.id;
      //Ensure we have depot line item for all
      final isinList = result.lineItems.map((e) => e.isin).toList();
      final depotItemsResponse = await supabase
          .from('depot_items')
          .select('id,isin')
          .eq('depot_id', depoID)
          .withConverter((data) => ModelConverter.modelList(
              data,
              (singleElement) => MapEntry(singleElement['isin'].toString(),
                  singleElement['id'].toString())))
          .execute();
      handleNoValueResponse(depotItemsResponse);
      isinList.removeWhere((isin) =>
          depotItemsResponse.data
              ?.any((isinMapping) => isinMapping.key == isin) ??
          false);
      Map<String, String> isinDepotItemMapping = {};
      isinDepotItemMapping.addEntries(depotItemsResponse.data ?? []);
      if (isinList.isNotEmpty) {
        //All items in here are missing a record until now
        final creatioResponse = await supabase
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
            .withConverter((data) => ModelConverter.modelList(
                data, (singleElement) => DepotItem.fromJson(singleElement)))
            .execute();
        final newRows = handleNeverNullResponse(creatioResponse);
        for (var element in newRows) {
          isinDepotItemMapping[element.isin] = element.id;
        }
      }

      final lineItemCreation = await supabase
          .from('line_items')
          .insert(
              result.lineItems
                  .map(
                    (e) => e.toCreateDto(
                      parentId,
                      isinDepotItemMapping[e.isin]!,
                    ),
                  )
                  .toList(),
              returning: ReturningOption.minimal)
          .execute();
      handleNoValueResponse(lineItemCreation);
    }

    return handleResponse(response, null);
  }

  Future<bool> deleteExport(String exportID) async {
    try {
      final result = await supabase
          .from('depot_exports')
          .delete(returning: ReturningOption.minimal)
          .match({'id': exportID}).execute();
      handleNoValueResponse(result);
      return true;
    } catch (ex) {
      return false;
    }
  }
}
