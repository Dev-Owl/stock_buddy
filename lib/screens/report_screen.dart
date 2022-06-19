import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stock_buddy/models/report_chart_model.dart';
import 'package:stock_buddy/repository/reporting_repository.dart';
import 'package:charts_flutter/flutter.dart' as charts;
/*

    Time chart:

    Check if we have other exports for this depot by its number
    Select date, total gain € for the same repo 
    Filter it by Isin if provided

    Total Kpi:
    Sum up total gain/loss €/% 

    List with overview:
    Arow shows trend based on existing data
    Unfold listtile to see all records for this position

      Main Tile:
    Up/Down | Isin |  Current
     Arrow  | Name |  Win/Loss
      
      Detail tile:
      | Export date | Win/Loss

*/

//TODO Add second chart to show invested money

class ReportingScreen extends StatefulWidget {
  final String? exportId;
  final List<String>? lineItemsIsin;
  final String depotId;
  const ReportingScreen({
    required this.depotId,
    this.exportId,
    this.lineItemsIsin,
    Key? key,
  }) : super(key: key);

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  late List<ReportChartModel> data;

  Future<void> _loadingReport() async {
    //await Future.delayed(const Duration(seconds: 5));
    final repo = ReportingRepository();
    data = await repo
        .buildReportingModel(widget.depotId, isinFilter: ['DE000A0Q4R36']);
  }

  List<charts.Series<ReportChartModel, DateTime>> _createChartingData() {
    return [
      charts.Series<ReportChartModel, DateTime>(
        id: 'Currentvalue',
        colorFn: (m, __) => m.winLoss < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        domainFn: (r, _) => DateTime(
          r.exportTime.year,
          r.exportTime.month,
          r.exportTime.day,
        ),
        measureFn: (r, _) => r.winLoss,
        data: data,
        displayName: 'Current value',
      )
    ];
  }

  final myNumericFormatter =
      charts.BasicNumericTickFormatterSpec.fromNumberFormat(
    NumberFormat.currency(
      decimalDigits: 2,
      locale: 'de',
      name: 'EUR',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report',
        ),
      ),
      body: FutureBuilder(
        future: _loadingReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              height: 350,
              width: 350,
              color: Colors.grey[600],
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: charts.TimeSeriesChart(
                  _createChartingData(),
                  animate: true,
                  behaviors: [charts.SeriesLegend()],
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    renderSpec: const charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.white,
                      ),
                    ),
                    tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                      zeroBound: false,
                      dataIsInWholeNumbers: false,
                    ),
                    tickFormatterSpec: myNumericFormatter,
                  ),
                  domainAxis: const charts.DateTimeAxisSpec(
                    showAxisLine: false,
                    renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.white,
                      ),
                    ),
                  ),
                  defaultRenderer: charts.LineRendererConfig(
                    includePoints: true,
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Crunching the numbers',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                    ),
                    const FaIcon(
                      FontAwesomeIcons.calculator,
                      size: 60,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                    ),
                    const SizedBox(
                      width: 150,
                      child: LinearProgressIndicator(
                        minHeight: 10,
                      ),
                    ),
                  ]),
            );
          }
        },
      ),
    );
  }
}
