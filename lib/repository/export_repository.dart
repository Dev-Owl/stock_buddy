import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/create_export_record.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/utils/ing_diba_export_reader.dart';
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef UserActionNeededCallback<T> = Future<T> Function();

class ExportRepositories extends BaseRepository {
  Future<List<ExportRecord>> getAllExports() async {
    final response = await supabase
        .from('depot_exports')
        .select()
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

  Future<ExportRecord?> importNewData(
    String pathToExportFile,
    UserActionNeededCallback<String> missingRepoNameQuestion,
  ) async {
    final reader = ExportReader();
    try {
      final result = await reader.parseFile(pathToExportFile);
      final depotRepo = DepotRepository();
      var repoID = await depotRepo.getRepositoryIdByNumber(result.depotNumber);
      if (repoID == null) {
        var newDepotName = await missingRepoNameQuestion();
        if (newDepotName.isEmpty) {
          newDepotName = result.customerName;
        }
        final depotRepo = DepotRepository();
        repoID =
            (await depotRepo.createNewDepot(newDepotName, result.depotNumber))
                .id;
      }

      final totalWinLoss = result.lineItems.fold<double>(
          0, (currentValue, e) => currentValue + e.currentWinLoss);

      final totalInvest = result.lineItems.fold<double>(
          0, (currentValue, e) => currentValue + e.totalPurchasePrice);

      final percentageTotalWinLoss = (totalWinLoss / totalInvest) * 100;

      final creationModel = CreateExportRecord(
        result.exportDate,
        result.customerName,
        result.depotNumber,
        totalWinLoss,
        percentageTotalWinLoss,
        repoID,
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
        final lineItemCreation = await supabase
            .from('line_items')
            .insert(
                result.lineItems
                    .map(
                      (e) => e.toCreateDto(
                        parentId,
                      ),
                    )
                    .toList(),
                returning: ReturningOption.minimal)
            .execute();
        handleNoValueResponse(lineItemCreation);
      }

      return handleResponse(response, null);
    } catch (ex) {
      return null;
    }
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
