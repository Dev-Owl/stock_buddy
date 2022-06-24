import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/models/report_screen_model.dart';
import 'package:stock_buddy/repository/reporting_repository.dart';
import 'package:stock_buddy/utils/text_helper.dart';
import 'package:stock_buddy/widgets/current_invested_chart.dart';
import 'package:stock_buddy/widgets/current_value_chart.dart';
import 'package:stock_buddy/widgets/percentage_pie_chart.dart';

//TODO Add a filter function to this screen, show line items in tick list
//     allow to add/remove them and reload the view

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
  late ReportScreenModel data;

  Future<void> _loadingReport() async {
    final repo = ReportingRepository();
    data = await repo.buildReportingModel(
      widget.depotId,
      isinFilter: widget.lineItemsIsin,
    );
  }

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
            return _getBody();
          } else {
            return _buildLoading();
          }
        },
      ),
    );
  }

  Widget _getBody() {
    final size = MediaQuery.of(context).size;
    final desktopMode = size.width > 600;
    final List<Widget> children = [];
    children.add(
      Container(
        height: 350,
        width: 350,
        color: Colors.grey[600],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: CurrentValueChar(
            chartData: data.valueChart,
          ),
        ),
      ),
    );
    children.add(
      Container(
        height: 350,
        width: 350,
        color: Colors.grey[600],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: CurrentInvestedChar(
            chartData: data.valueChart,
          ),
        ),
      ),
    );
    final title = Theme.of(context).textTheme.titleMedium;
    final lastKnownData = data.valueChart.last;
    final currencyWinLoss = lastKnownData.winLoss;
    final percentageWinLoss =
        ((currencyWinLoss / lastKnownData.totalInvest) * 100);
    children.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Overivew ${data.totalPositions} elements',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  TextHelper.number(
                    currencyWinLoss,
                    decoration: '€',
                    context: context,
                    style: title,
                  ),
                  TextHelper.number(
                    percentageWinLoss,
                    decoration: '%',
                    context: context,
                    style: title,
                  ),
                ],
              ),
              ...data.lastItems.map(
                (e) => ListTile(
                    title: Text(e.name),
                    subtitle: Text('ISIN: ${e.isin}'),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextHelper.number(
                          e.currentWinLoss,
                          decoration: '€',
                          context: context,
                          style: title,
                        ),
                        TextHelper.number(
                          e.currentWindLossPercent,
                          decoration: '%',
                          context: context,
                          style: title,
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
    children.add(Container(
        height: 350,
        width: 350,
        color: Colors.grey[600],
        child: PercentagePieChart(items: data.lastItems)));
    final crossAxisCount = min(4, size.width ~/ 350);
    if (desktopMode) {
      return GridView.count(
        padding: const EdgeInsets.all(5),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: children,
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(5),
        children: children,
      );
    }
  }

  Widget _buildLoading() => Center(
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
