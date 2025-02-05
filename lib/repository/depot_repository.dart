import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:uuid/uuid.dart';

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
    var queryParameter = {'keys': '["$number"]'};
    return backend.requestWithConverter(
        backend.get(
            "stockbuddy/_partition/depot/_design/depot/_view/numberToId",
            queryParameter), (data) {
      if (data["rows"] != null) {
        final rows = data["rows"] as List;
        if (rows.isEmpty) {
          return null;
        }
        return data["rows"][0]["value"].toString();
      }
      throw Exception("No depot found with number $number");
    });
  }

  Future<DataDepot> createNewDepot(String name, String number) async {
    final newDepot = DataDepot(
      name,
      number,
      DateTime.now(),
      'depot:${Uuid().v4()}',
      null,
      0,
      0,
      0,
      "",
      null,
    );
    backend.requestWithConverter(
      backend.put("stockbuddy/${newDepot.id}", newDepot.toJson()),
      (data) {
        newDepot.rev = data["rev"];
      },
    );
    return newDepot;
  }

  Future<bool> deleteDepot(String id, String rev) async {
    return delete(id, rev);
  }

  Future<DataDepot> getDepotById(String id) async {
    return await backend
        .requestWithConverter(backend.get("stockbuddy/$id", null), (data) {
      return DataDepot.fromJson(data);
    });
  }

  Future<String> updateDepotNotes(String id, String notes) async {
    final depot = await getDepotById(id);
    depot.notes = notes;
    backend.requestWithConverter(
        backend.put("stockbuddy/${depot.id}", depot.toJson()), (data) {
      depot.rev = data["rev"];
    });
    return depot.rev!;
  }
}
