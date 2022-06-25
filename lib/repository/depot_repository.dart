import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/data_contract_helper.dart';
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepotRepository extends BaseRepository {
  Future<String?> getRepositoryIdByNumber(String number) async {
    final request = await supabase
        .from('depots')
        .select('id')
        .eq('number', number)
        .withConverter((data) => data[0]['id'].toString())
        .execute();
    return request.data;
  }

  Future<DataDepot> createNewDepot(String name, String number) async {
    final response = await supabase
        .from('depots')
        .insert(removeDataContracFromMap(
            DataDepot.forInsert(name, number).toJson()))
        .withConverter(
          (data) => ModelConverter.first(
            data,
            (singleElement) => DataDepot.fromJson(singleElement),
          ),
        )
        .execute();
    return handleNeverNullResponse<DataDepot>(response);
  }

  Future<List<DataDepot>> getAllDepots() async {
    final response = await supabase
        .rpc('getdepotstats')
        .withConverter((data) => ModelConverter.modelList(
            data, (singleElement) => DataDepot.fromJson(singleElement)))
        .execute();
    return handleResponse(response, []);
  }

  Future<bool> deleteDepot(String id) async {
    try {
      final result = await supabase
          .from('depots')
          .delete(returning: ReturningOption.minimal)
          .match({'id': id}).execute();
      handleNoValueResponse(result);
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<void> updateDepotNotes(String id, String notes) async {
    final result = await supabase
        .from('depots')
        .update({'notes': notes})
        .eq('id', id)
        .execute();
    handleNoValueResponse(result);
  }
}
