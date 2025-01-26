import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/data_contract_helper.dart';
import 'package:stock_buddy/utils/model_converter.dart';

class DepotRepository extends BaseRepository {
  DepotRepository(super.backend);

  Future<List<DataDepot>> getAllDepots({String? filterById}) async {
    final queryParameter = {
      'include_docs': 'true',
    };
    if (filterById != null) {
      queryParameter["keys"] = '%5B"$filterById"%5D';
    }

    return backend.requestWithConverter(
        backend.get("stockbuddy/_partition/depot/_design/depot/_view/list",
            queryParameter), (data) {
      var result = <DataDepot>[];
      if (data["rows"] != null) {
        for (var item in data["rows"]) {
          result.add(DataDepot.fromJson(item["doc"]));
        }
      }
      return result;
    });
  }

  Future<String?> getRepositoryIdByNumber(String number) async {
    return null;

    /*
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
    */
  }

  Future<DataDepot> createNewDepot(String name, String number) async {
    return DataDepot(
      name,
      number,
      DateTime.now(),
      '0',
      0,
      0,
      0,
      null,
      null,
    );
    /*
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
    */
  }

  Future<bool> deleteDepot(String id) async {
    return false;
    /*
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
    */
  }

  Future<void> updateDepotNotes(String id, String notes) async {
    /*
    return await backend.runAuthenticatedRequest<void>((client) async {
      final result = await client
          .from('depots')
          .update(
            {'notes': notes},
          )
          .eq('id', id)
          .select();
    });
  }
  */
  }
}
