import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/models/export_line_item.dart';
import 'package:stock_buddy/models/report_screen_model.dart';
import 'package:stock_buddy/repository/reporting_repository.dart';
import 'package:stock_buddy/utils/text_helper.dart';
import 'package:stock_buddy/widgets/current_invested_chart.dart';
import 'package:stock_buddy/widgets/current_value_chart.dart';
import 'package:stock_buddy/widgets/percentage_pie_chart.dart';

//TODO Allow to also filter by tag on this screen

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
  ReportScreenModel? data;
  List<String> isinFilter = [];
  List<ExportLineItem> allAvalibleItems = [];
  @override
  void initState() {
    super.initState();
    isinFilter = widget.lineItemsIsin ?? [];
  }

  Future<void> _loadingReport() async {
    final repo = ReportingRepository();
    data = await repo.buildReportingModel(
      widget.depotId,
      isinFilter: isinFilter,
    );
    if (allAvalibleItems.isEmpty) {
      allAvalibleItems.addAll(data!.lastItems);
    }

    isinFilter.addAll(data!.lastItems.map((e) => e.isin).toList());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadingReport(),
        builder: (context, snapshot) {
          late final Widget body;
          final loadingDone = snapshot.connectionState == ConnectionState.done;
          if (loadingDone) {
            body = _getBody();
          } else {
            body = _buildLoading();
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Report',
              ),
              actions: [
                if (loadingDone)
                  IconButton(
                    onPressed: () {
                      _onScreenFilter();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.filter,
                    ),
                  ),
              ],
            ),
            body: body,
          );
        });
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
            chartData: data!.valueChart,
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
            chartData: data!.valueChart,
          ),
        ),
      ),
    );
    final title = Theme.of(context).textTheme.titleMedium;
    final lastKnownData = data!.valueChart.last;
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
                'Overivew ${data!.totalPositions} elements',
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
              ...data!.lastItems.map(
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
        child: PercentagePieChart(items: data!.lastItems)));
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

  Future<void> _onScreenFilter() {
    final txtController = TextEditingController();
    String popupIsinFilter = "";
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: const Text('Filter'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      //Apply changed filter
                    });
                  },
                  child: const Text('Apply'))
            ],
            content: SizedBox(
              height: 300.0,
              width: 300.0,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateList) {
                return Column(
                  children: [
                    TextField(
                      controller: txtController,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                        onPressed: () {
                          setStateList(
                              () => popupIsinFilter = txtController.text);
                        },
                        icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
                      )),
                    ),
                    ListTile(
                      title: const Text('Name'),
                      subtitle: const Text('ISIN'),
                      trailing: Checkbox(
                        onChanged: (d) {
                          if (d == true) {
                            setStateList((() {
                              isinFilter.clear();
                              isinFilter.addAll(allAvalibleItems
                                  .where((element) =>
                                      popupIsinFilter.isEmpty ||
                                      element.isin == popupIsinFilter ||
                                      element.isin.contains(popupIsinFilter))
                                  .map((e) => e.isin));
                            }));
                          } else {
                            setStateList((() => isinFilter.clear()));
                          }
                        },
                        value: data!.lastItems.length == isinFilter.length,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: allAvalibleItems
                            .where((element) =>
                                popupIsinFilter.isEmpty ||
                                element.isin == popupIsinFilter ||
                                element.isin.contains(popupIsinFilter))
                            .map((e) => CheckboxListTile(
                                  value: isinFilter.contains(e.isin),
                                  title: Text(e.name),
                                  subtitle: Text(e.isin),
                                  onChanged: (newState) {
                                    if (newState == true) {
                                      setStateList(() {
                                        isinFilter.add(e.isin);
                                      });
                                    } else {
                                      setStateList(() {
                                        isinFilter.remove(e.isin);
                                      });
                                    }
                                  },
                                ))
                            .toList(),
                      ),
                    )
                  ],
                );
              }),
            ),
          );
        });
  }
}
