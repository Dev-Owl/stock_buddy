import 'package:stock_buddy/models/database_depot.dart';
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

  Future<String> getCurrentRevById(String id) async {
    return backend.head("stockbuddy/$id").then((value) {
      return value.headers.value("ETag")!.replaceAll('"', "");
    });
  }

  Future<String?> getRepositoryIdByNumber(String number) async {
    var queryParameter = <String, String>{};
    queryParameter["keys"] = '%5B"$number"%5D';
    return backend.requestWithConverter(
        backend.get(
            "stockbuddy/_partition/depot/_design/depot/_view/numberToId",
            queryParameter), (data) {
      if (data["rows"] != null) {
        return data["rows"]["value"]?.toString();
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
    return backend.requestWithConverter(
        backend.delete("stockbuddy/$id", queryParameters: {"rev": rev}),
        (data) {
      return true;
    });
  }

  Future<String> updateDepotNotes(String id, String notes) async {
    final depot = await backend
        .requestWithConverter(backend.get("stockbuddy/$id", null), (data) {
      return DataDepot.fromJson(data);
    });
    depot.notes = notes;
    backend.requestWithConverter(
        backend.put("stockbuddy/${depot.id}", depot.toJson()), (data) {
      depot.rev = data["rev"];
    });
    return depot.rev!;
  }
}
