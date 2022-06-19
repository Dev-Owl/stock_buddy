import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/data_contract_helper.dart';
import 'package:stock_buddy/utils/model_converter.dart';

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
}
