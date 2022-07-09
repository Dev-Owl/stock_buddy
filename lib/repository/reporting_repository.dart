import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/export_line_item.dart';
import 'package:stock_buddy/models/report_chart_model.dart';
import 'package:stock_buddy/models/report_screen_model.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/model_converter.dart';

class ReportingRepository extends BaseRepository {
  Future<ReportScreenModel> buildReportingModel(String depotID,
      {List<String>? isinFilter}) async {
    late final List<ReportChartModel> chartingData;
    final isinFilterPresent = isinFilter != null && isinFilter.isNotEmpty;

    final response = await supabase
        .rpc(isinFilterPresent ? 'getdepotchartbyline' : 'getdepotchart',
            params: {
              'depotid': depotID,
              if (isinFilterPresent) 'isinf': isinFilter,
            })
        .withConverter((data) => ModelConverter.modelList(
            data, (singleElement) => ReportChartModel.fromJson(singleElement)))
        .execute();
    chartingData = handleResponse(response, []);
    var positions = isinFilter?.length ?? 0;
    if (isinFilter == null || isinFilter.isEmpty) {
      final result = await supabase
          .rpc(
            'totallineitemsforlastexport',
            params: {
              'depotid': depotID,
            },
          )
          .withConverter((data) => data as int)
          .execute();
      positions = result.data ?? 0;
    }
    var lastLineItemsQuery = supabase.from('depot_exports').select('''
            line_items(
              *,
              depot_items(tags)
            )                    
        ''').eq('depot_id', depotID);

    if (isinFilter?.isNotEmpty ?? false) {
      lastLineItemsQuery =
          lastLineItemsQuery.in_('line_items.isin', isinFilter!);
    }
    final lastLineItemsQueryCompleted = lastLineItemsQuery.order(
      'export_time',
      ascending: false,
    );

    final lastLineItems = await lastLineItemsQueryCompleted
        .limit(1)
        .withConverter(_convert)
        .execute();
    return ReportScreenModel(
      chartingData,
      positions,
      (lastLineItems.data ?? [])
        ..sort(
          ((a, b) =>
              a.currentWindLossPercent.compareTo(b.currentWindLossPercent)),
        ),
    );
  }
}

List<ExportLineItem> _convert(data) {
  final List<ExportLineItem> result = [];

  final records = (data as List).first;
  final listOfJsonData = (records as Map).values.toList().first;
  for (final map in listOfJsonData) {
    map['tags'] = ((map['depot_items'] as Map).values.first as List?);
    if (map['tags'] == null) {
      map['tags'] = [];
    }
    result.add(ExportLineItem.fromJson(map));
  }

  return result;
}
