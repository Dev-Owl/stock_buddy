import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/repository/export_line_repository.dart';
import 'package:stock_buddy/utils/model_converter.dart';

class DepotLineRepository extends BaseRepository {
  final Map<String, int> _totalCache = {};

  DepotLineRepository(super.backend);

  Future<bool> updateLineDetails(
    String id,
    String note,
    List<String> tags,
    bool active,
  ) async {
    return await backend.runAuthenticatedRequest<bool>((client) async {
      await client.from('depot_items').update(
        {
          'note': note,
          'tags': tags,
          'active': active,
        },
        options: const FetchOptions(head: true),
      ).eq('id', id);
      return true;
    });
  }

  Future<List<DepotItem>> allItemsByDepotId(String depotId) {
    return backend.runAuthenticatedRequest<List<DepotItem>>((client) async {
      return await client
          .from('depot_items')
          .select()
          .eq('depot_id', depotId)
          .withConverter((data) => ModelConverter.modelList(
              data, (singleElement) => DepotItem.fromJson(singleElement)));
    });
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
    return await backend
        .runAuthenticatedRequest<RemoteDataSourceDetails<DepotItem>>(
            (client) async {
      var result = await client
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
              data, (singleElement) => DepotItem.fromJson(singleElement)));

      if (_totalCache.containsKey(depotId) == false) {
        final response = await client
            .from("depot_items")
            .select('id', const FetchOptions(count: CountOption.exact))
            .eq("depot_id", depotId);
        handleNoValueResponse(response);
        _totalCache[depotId] = response.count ?? 0;
      }

      return RemoteDataSourceDetails<DepotItem>(
        _totalCache[depotId]!,
        result,
        filteredRows:
            filter == null && showActiveOnly == false ? null : result.length,
      );
    });
  }
}

class DepotLineItemsDataSource extends AdvancedDataTableSource<DepotItem> {
  final GetRowCallback<DepotItem> getRowCallback;
  final String depotId;
  final StockBuddyBackend backend;
  late final DepotLineRepository _repo;
  String? _lastSearchQuery;
  bool _showActiveOnly = true;

  DepotLineItemsDataSource({
    required this.depotId,
    required this.getRowCallback,
    required this.backend,
  }) {
    _repo = DepotLineRepository(backend);
  }

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
