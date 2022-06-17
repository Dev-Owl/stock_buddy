import 'package:stock_buddy/models/depot_line_item.dart';

class Depot {
  final DateTime exportDate;
  final String customerName;
  final String depotNumber;
  final List<DepotLineItem> lineItems;

  Depot(
    this.exportDate,
    this.customerName,
    this.depotNumber,
    this.lineItems,
  );
}
