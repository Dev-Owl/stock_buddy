import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/repository/base_repository.dart';

class DepotRepository extends BaseRepository {
  Future<String?> getRepositoryIdByNumber(String id) async {
    final request = await supabase
        .from('depots')
        .select('id')
        .eq('number', id)
        .withConverter((data) => data['id'].toString())
        .execute();
    return request.data;
  }

  //TODO Create a new repo here with name and number

  //TODO create query to return depot list based on model

}
