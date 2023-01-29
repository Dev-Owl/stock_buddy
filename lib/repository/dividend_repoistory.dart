import 'package:stock_buddy/models/dividend_item.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/model_converter.dart';

class DividendRepository extends BaseRepository {
  DividendRepository(super.backend);

  Future<List<DividendItem>> getAllDividendsBetween(
      String depotId, DateTime start, DateTime end) async {
    return await backend
        .runAuthenticatedRequest<List<DividendItem>>((client) async {
      return await client
          .from('dividends')
          .select()
          .eq('depot_id', depotId)
          .gte('booked_at', start)
          .lte('booked_at', end)
          .withConverter((data) => ModelConverter.modelList(
              data, (singleElement) => DividendItem.fromJson(singleElement)));
    });
  }

  Future<void> import(List<DividendItem> addList) async {
    if (addList.isEmpty) return;
    await backend.runAuthenticatedRequest((clinet) async {
      await clinet.from('dividends').insert(addList);
    });
  }
}
