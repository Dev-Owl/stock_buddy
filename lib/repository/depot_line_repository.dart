import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:flutter/material.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/export_line_repository.dart';
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepotLineRepository extends BaseRepository {
  final Map<String, int> _totalCache = {};

  Future<bool> updateLineDetails(
      String id, String note, List<String> tags) async {
    final result = await supabase
        .from('depot_items')
        .update(
          {'note': note, 'tags': tags},
          returning: ReturningOption.minimal,
        )
        .eq('id', id)
        .execute();
    handleNoValueResponse(result);
    return true;
  }

  Future<RemoteDataSourceDetails<DepotItem>> getPagedListOfItems({
    required String depotId,
    String? filter,
    required int offset,
    required int orderIndex,
    required int pageSize,
    required bool sortAsc,
    required bool showActiveOnly,
  }) async {
    const orderColumnMap = {
      0: 'isin',
      1: 'name',
      2: 'tags',
      3: 'note',
      4: 'last_total_value',
      5: 'last_win_loss',
      6: 'last_win_loss_percent',
    };
    final rangeTo = offset + pageSize;
    var result = await supabase
        .rpc(
          'depotlinetable',
          params: {
            'depotidfilter': depotId,
            'filter': filter,
            'activeonly': showActiveOnly,
          },
        )
        .order(orderColumnMap[orderIndex]!, ascending: sortAsc)
        .range(offset, rangeTo)
        .withConverter((data) => ModelConverter.modelList(
            data, (singleElement) => DepotItem.fromJson(singleElement)))
        .execute();
    handleNeverNullResponse(result);
    if (_totalCache.containsKey(depotId) == false) {
      final response = await supabase
          .from("depot_items")
          .select('id')
          .eq("depot_id", depotId)
          .execute(count: CountOption.exact);
      handleNoValueResponse(response);
      _totalCache[depotId] = response.count ?? 0;
    }
    return RemoteDataSourceDetails<DepotItem>(
      _totalCache[depotId]!,
      result.data!,
      filteredRows: filter == null ? null : result.data!.length,
    );
  }
}

class DepotLineItemsDataSource extends AdvancedDataTableSource<DepotItem> {
  final GetRowCallback<DepotItem> getRowCallback;
  final String depotId;
  final _repo = DepotLineRepository();
  String? _lastSearchQuery;
  bool _showActiveOnly = true;

  DepotLineItemsDataSource({
    required this.depotId,
    required this.getRowCallback,
  });

  @override
  Future<RemoteDataSourceDetails<DepotItem>> getNextPage(
      NextPageRequest pageRequest) {
    return _repo.getPagedListOfItems(
      depotId: depotId,
      filter: _lastSearchQuery,
      offset: pageRequest.offset,
      orderIndex: pageRequest.columnSortIndex ?? 2,
      pageSize: pageRequest.pageSize,
      sortAsc: pageRequest.sortAscending ?? true,
      showActiveOnly: _showActiveOnly,
    );
  }

  void reloadCurrentView() {
    forceRemoteReload = true;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    return getRowCallback(lastDetails!.rows[index]);
  }

  @override
  int get selectedRowCount => 0; //this source doesnt support this

  void applyServerSideFilter(String? newSearchQuery, bool showActiveOnly) {
    if (newSearchQuery != _lastSearchQuery ||
        _showActiveOnly != showActiveOnly) {
      _lastSearchQuery = newSearchQuery;
      _showActiveOnly = showActiveOnly;
      setNextView();
    }
  }
}
