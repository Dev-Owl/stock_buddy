import 'package:advanced_datatable/datatable.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/models/export_line_item.dart';
import 'package:stock_buddy/repository/export_line_repository.dart';
import 'package:stock_buddy/screens/report_screen.dart';
import 'package:stock_buddy/utils/data_cell_helper.dart';

class ExportDetailScreen extends StatefulWidget {
  final String exportId;
  const ExportDetailScreen({required this.exportId, Key? key})
      : super(key: key);

  @override
  State<ExportDetailScreen> createState() => _ExportDetailScreenState();
}

class _ExportDetailScreenState extends State<ExportDetailScreen> {
  final _searchController = TextEditingController();
  late final ExportLineDataAdapter _source;
  var _sortIndex = 0;
  var _sortAsc = true;
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  String noSelectionBadgeContent = '';
  @override
  void initState() {
    _source = ExportLineDataAdapter(
        parentExportId: widget.exportId,
        getRowCallback: _buildRow,
        onNewPage: (page) {
          setState(() {
            noSelectionBadgeContent = page.totalRows.toString();
          });
        });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DataRow _buildRow(ExportLineItem row) {
    return DataRow(
      selected: _source.isSelected(row.id),
      onSelectChanged: (state) {
        final addToList = state ?? false;
        if (addToList && _source.isSelected(row.id) == false) {
          _source.addSelectedRow(row);
          _rowSelectionChanged();
        } else if (addToList == false && _source.isSelected(row.id)) {
          _source.removeSelectedRow(row);
          _rowSelectionChanged();
        }
      },
      cells: [
        CellHelper.textCell(row.isin),
        CellHelper.textCell(row.name),
        CellHelper.number(
          row.amount,
          colorCode: false,
          decimalPlaces: 2,
          decoration: " ${row.amountType}",
        ),
        CellHelper.number(
          row.singlePurchasePrice,
          decoration: row.currency,
          colorCode: false,
        ),
        CellHelper.number(
          row.totalPurchasePrice,
          colorCode: false,
          decoration: row.currency,
        ),
        CellHelper.number(
          row.currentValue,
          decoration: row.currency,
          colorCode: false,
        ),
        CellHelper.number(
          row.currentTotalValue,
          decoration: row.currency,
          colorCode: false,
        ),
        CellHelper.textCell(row.marketName),
        CellHelper.number(
          row.currentWinLoss,
          decoration: row.currency,
          context: context,
        ),
        CellHelper.number(
          row.currentWindLossPercent,
          decoration: '%',
          context: context,
        ),
      ],
    );
  }

  void _rowSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final badgeContentForActionButton = _source.selectedRowCount == 0
        ? _source.lastDetails?.totalRows.toString() ?? noSelectionBadgeContent
        : _source.selectedRowCount.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by ISIN',
                      ),
                      onSubmitted: (vlaue) {
                        _source.applyServerSideFilter(_searchController.text);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.text = '';
                    });
                    _source.applyServerSideFilter(_searchController.text);
                  },
                  icon: const Icon(Icons.clear),
                ),
                IconButton(
                  onPressed: () =>
                      _source.applyServerSideFilter(_searchController.text),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Positioned(
            top: 55,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 55 * 2,
            child: SingleChildScrollView(
              child: AdvancedPaginatedDataTable(
                addEmptyRows: false,
                source: _source,
                showHorizontalScrollbarAlways: true,
                sortAscending: _sortAsc,
                sortColumnIndex: _sortIndex,
                showFirstLastButtons: true,
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const [10, 20, 30, 50],
                loadingWidget: () =>
                    const Center(child: CircularProgressIndicator()),
                onRowsPerPageChanged: (newRowsPerPage) {
                  if (newRowsPerPage != null) {
                    setState(() {
                      _rowsPerPage = newRowsPerPage;
                    });
                  }
                },
                columns: [
                  DataColumn(
                    label: const Text('ISIN'),
                    numeric: false,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Name'),
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Amount'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Price'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Total price'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Current price'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Current total'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Market'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Win/Loss'),
                    numeric: true,
                    onSort: setSort,
                  ),
                  DataColumn(
                    label: const Text('Win/Loss %'),
                    numeric: true,
                    onSort: setSort,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Badge(
          toAnimate: true,
          shape: BadgeShape.circle,
          badgeColor: Colors.red,
          borderRadius: BorderRadius.circular(8),
          showBadge: badgeContentForActionButton.isNotEmpty,
          badgeContent: Text(
            badgeContentForActionButton,
            style: const TextStyle(color: Colors.white),
          ),
          position: BadgePosition.bottomEnd(bottom: -20, end: -20),
          child: const FaIcon(FontAwesomeIcons.chartLine),
        ),
        onPressed: () {
          final rowsForAnalytics = _source.selectedRows
              .map(
                (e) => e.isin,
              )
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportingScreen(
                exportId: widget.exportId,
                lineItemsIsin: rowsForAnalytics,
              ),
            ),
          );
        },
      ),
    );
  }

  void setSort(int i, bool asc) => setState(() {
        _sortIndex = i;
        _sortAsc = asc;
      });
}
