import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:flutter/material.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/export_line_item.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExportLineRepository extends BaseRepository {
  final Map<String, int> _totalCache = {};

  Future<RemoteDataSourceDetails<ExportLineItem>> getPagedListOfItems({
    required String exportId,
    int offset = 0,
    int pageSize = 10,
    int orderIndex = 2,
    bool sortAsc = true,
    String? isinFilter,
  }) async {
    const orderColumnMap = {
      0: 'isin',
      1: 'name',
      2: 'amount',
      3: 'single_purchase_price',
      4: 'total_purchase_price',
      5: 'current_value',
      6: 'current_total_value',
      7: 'market_name',
      8: 'current_win_loss',
      9: 'current_win_loss_percent'
    };
    var query = supabase.from("line_items").select().eq("export_id", exportId);
    if (isinFilter != null) {
      query = query.like("isin", "%$isinFilter%");
    }
    final rangeTo = offset + pageSize;
    final response = await query
        .order(orderColumnMap[orderIndex]!, ascending: sortAsc)
        .range(offset, rangeTo)
        .withConverter<List<ExportLineItem>>(
          (data) => ModelConverter.modelList(
            data,
            (singleElement) => ExportLineItem.fromJson(
              singleElement,
            ),
          ),
        )
        .execute();
    handleNeverNullResponse(response);

    if (_totalCache.containsKey(exportId) == false) {
      final response = await supabase
          .from("line_items")
          .select('id')
          .eq("export_id", exportId)
          .execute(count: CountOption.exact);
      handleNoValueResponse(response);
      _totalCache[exportId] = response.count ?? 0;
    }
    return RemoteDataSourceDetails<ExportLineItem>(
      _totalCache[exportId]!,
      response.data!,
      filteredRows: isinFilter == null ? null : response.data!.length,
    );
  }
}

typedef GetRowCallback<T> = DataRow Function(T currentRow);
typedef OnNewPageLoadCallback<T> = void Function(
    RemoteDataSourceDetails<T> newpage);

class ExportLineDataAdapter extends AdvancedDataTableSource<ExportLineItem> {
  final _repo = ExportLineRepository();
  final List<ExportLineItem> selectedRows = [];
  final String parentExportId;
  String? _lastSearchQuery;
  final GetRowCallback<ExportLineItem> getRowCallback;
  final OnNewPageLoadCallback<ExportLineItem> onNewPage;
  ExportLineDataAdapter({
    required this.parentExportId,
    required this.getRowCallback,
    required this.onNewPage,
  });

  void addSelectedRow(ExportLineItem row) {
    selectedRows.add(row);
    notifyListeners();
  }

  void removeSelectedRow(ExportLineItem row) {
    selectedRows.removeWhere((element) => element.id == row.id);
    notifyListeners();
  }

  void applyServerSideFilter(String? newSearchQuery) {
    if (newSearchQuery != _lastSearchQuery) {
      _lastSearchQuery = newSearchQuery;
      setNextView();
    }
  }

  @override
  Future<RemoteDataSourceDetails<ExportLineItem>> getNextPage(
      NextPageRequest pageRequest) async {
    final result = await _repo.getPagedListOfItems(
      exportId: parentExportId,
      isinFilter: _lastSearchQuery,
      offset: pageRequest.offset,
      orderIndex: pageRequest.columnSortIndex ?? 2,
      pageSize: pageRequest.pageSize,
      sortAsc: pageRequest.sortAscending ?? true,
    );
    onNewPage(result);
    return result;
  }

  @override
  DataRow? getRow(int index) {
    final row = lastDetails!.rows[index];
    return getRowCallback(row);
  }

  bool isSelected(String id) {
    return selectedRows.any((element) => element.id == id);
  }

  @override
  int get selectedRowCount => selectedRows.length;
}
