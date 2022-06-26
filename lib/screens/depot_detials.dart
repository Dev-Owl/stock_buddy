/*
  Tabs one for items one for exports (show number badge on each)
  - Show known line items in a list (data table)
    -> Filter by isin and/or tag
    -> Name,Isin,Tags(as comma), last value, last %win, last known date
  - On row click allow to set tags and note in popup
*/

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/screens/depot_details_items.dart';
import 'package:stock_buddy/screens/depot_details_main.dart';
import 'package:stock_buddy/screens/export_overview_screen.dart';
import 'package:stock_buddy/screens/report_screen.dart';

class DepotDetailPage extends StatefulWidget {
  final String depotId;
  const DepotDetailPage({required this.depotId, Key? key}) : super(key: key);

  @override
  State<DepotDetailPage> createState() => _DepotDetailPageState();
}

class _DepotDetailPageState extends State<DepotDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Depot details',
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: FaIcon(FontAwesomeIcons.book)),
              Tab(icon: FaIcon(FontAwesomeIcons.vault)),
              Tab(icon: Icon(FontAwesomeIcons.table)),
              Tab(icon: Icon(FontAwesomeIcons.chartLine)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DepotDetailsMain(depotId: widget.depotId),
            DepotDetailsLineItems(depotId: widget.depotId),
            ExportOverviewScreen(depotId: widget.depotId),
            ReportingScreen(depotId: widget.depotId, embededMode: true)
          ],
        ),
      ),
    );
  }
}
