import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/models/create_depot_item.dart';
import 'package:stock_buddy/models/create_export_record.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/utils/duplicate_export_exception.dart';
import 'package:stock_buddy/utils/ing_diba_export_reader.dart';
import 'package:stock_buddy/utils/model_converter.dart';

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

  Future<ExportRecord?> importNewData(
    String pathToExportFile,
    UserActionNeededCallback<String> missingRepoNameQuestion,
  ) async {
    final reader = ExportReader();

    final result = await reader.parseFile(pathToExportFile);
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
