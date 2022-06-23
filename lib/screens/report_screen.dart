import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/models/report_screen_model.dart';
import 'package:stock_buddy/repository/reporting_repository.dart';
import 'package:stock_buddy/widgets/current_invested_chart.dart';
import 'package:stock_buddy/widgets/current_value_chart.dart';

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
  late ReportScreenModel data;

  Future<void> _loadingReport() async {
    //await Future.delayed(const Duration(seconds: 5));
    final repo = ReportingRepository();
    data = await repo
        .buildReportingModel(widget.depotId, isinFilter: ['DE000A0Q4R36']);
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
    children.add(const ListTile(
      leading: FaIcon(
        FontAwesomeIcons.database,
      ),
      title: Text('Key figures'),
      subtitle: Text('placeholder'),
    ));
    final crossAxisCount = size.width ~/ 350;
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
