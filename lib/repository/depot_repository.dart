import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/data_contract_helper.dart';
import 'package:stock_buddy/utils/model_converter.dart';

class DepotRepository extends BaseRepository {
  DepotRepository(super.backend);

  Future<String?> getRepositoryIdByNumber(String number) async {
    return await backend.runAuthenticatedRequest<String?>((client) async {
      final request = await client
          .from('depots')
          .select('id')
          .eq('number', number)
          .withConverter((data) {
        String? result;
        try {
          result = data[0]['id'].toString();
          return result;
        } catch (ex) {
          return result;
        }
      });
      return request;
    });
  }

  Future<DataDepot> createNewDepot(String name, String number) async {
    return await backend.runAuthenticatedRequest<DataDepot>((client) async {
      final response = await client
          .from('depots')
          .insert(removeDataContracFromMap(
              DataDepot.forInsert(name, number).toJson()))
          .select()
          .withConverter(
            (data) => ModelConverter.first(
              data,
              (singleElement) => DataDepot.fromJson(singleElement),
            ),
          );
      return response;
    });
  }

  Future<List<DataDepot>> getAllDepots({String? filterById}) async {
    Map<String, String>? optionalFilter;
    if (filterById != null) {
      optionalFilter = {
        'depotid': filterById,
      };
    }
    return await backend
        .runAuthenticatedRequest<List<DataDepot>>((client) async {
      final response = await client
          .rpc(
            'getdepotstats',
            params: optionalFilter,
          )
          .withConverter((data) => ModelConverter.modelList(
              data, (singleElement) => DataDepot.fromJson(singleElement)));

      return response;
    });
  }

  Future<bool> deleteDepot(String id) async {
    //TODO test me
    return await backend.runAuthenticatedRequest<bool>((client) async {
      try {
        final result =
            await client.from('depots').delete().match({'id': id}).select(
          'id',
        );
      } catch (ex) {
        return false;
      }
      return true;
    });
  }

  Future<void> updateDepotNotes(String id, String notes) async {
    //TODO test me
    return await backend.runAuthenticatedRequest<void>((client) async {
      final result = await client
          .from('depots')
          .update(
            {'notes': notes},
            options: const FetchOptions(
              forceResponse: true,
            ),
          )
          .eq('id', id)
          .select();

      handleNoValueResponse(result);
    });
  }
}
