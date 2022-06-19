import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/report_chart_model.dart';
import 'package:stock_buddy/repository/base_repository.dart';
import 'package:stock_buddy/utils/model_converter.dart';

class ReportingRepository extends BaseRepository {
  Future<List<ReportChartModel>> buildReportingModel(String depotID,
      {List<String>? isinFilter}) async {
    late final List<ReportChartModel> chartingData;
    final isinFilterPresent = isinFilter == null;

    final response = await supabase
        .rpc(isinFilterPresent ? 'getdepotchartbyline' : 'getdepotchart',
            params: {
              'param': depotID,
              if (isinFilterPresent) 'isinf': isinFilter,
            })
        .withConverter((data) => ModelConverter.modelList(
            data, (singleElement) => ReportChartModel.fromJson(singleElement)))
        .execute();

    chartingData = handleResponse(response, []);

    return chartingData;
  }
}
