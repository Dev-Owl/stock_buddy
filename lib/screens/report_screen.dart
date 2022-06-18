import 'package:flutter/material.dart';

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

class ReportingScreen extends StatefulWidget {
  final String exportId;
  final List<String> lineItemsIsin;
  const ReportingScreen({
    required this.exportId,
    required this.lineItemsIsin,
    Key? key,
  }) : super(key: key);

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report',
        ),
      ),
      body: Container(),
    );
  }
}
