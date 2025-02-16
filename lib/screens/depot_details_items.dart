import 'dart:math';

import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/repository/depot_line_repository.dart';
import 'package:stock_buddy/utils/data_cell_helper.dart';
import 'package:stock_buddy/utils/snackbar_extension.dart';
import 'package:stock_buddy/widgets/depot_detail_line.dart';

class DepotDetailsLineItems extends StatefulWidget {
  final String depotId;
  const DepotDetailsLineItems({required this.depotId, super.key});

  @override
  State<DepotDetailsLineItems> createState() => _DepotDetailsLineItemsState();
}

class _DepotDetailsLineItemsState extends State<DepotDetailsLineItems> {
  final _searchController = TextEditingController();
  late final DepotLineItemsDataSource _source;
  var _sortIndex = 0;
  var _sortAsc = true;
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  var showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _source = DepotLineItemsDataSource(
      backend: context.read<StockBuddyBackend>(),
      depotId: widget.depotId,
      getRowCallback: (DepotItem row) {
        var note = row.note?.substring(0, min(row.note?.length ?? 0, 30)) ?? '';
        if (note.isNotEmpty && note.length > 30) {
          note = "$note...";
        }
        return DataRow(
          onSelectChanged: (value) async {
            final note = TextEditingController(
              text: row.note,
            );
            final lineItemUpdateController = TagController();
            await showDialog(
                context: context,
                builder: (c) {
                  return AlertDialog(
                    content: SizedBox(
                      width: 350,
                      height: 250,
                      child: DepotLineUpdate(
                        controller: note,
                        data: row,
                        tagController: lineItemUpdateController,
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(c);
                          },
                          child: const Text('OK'))
                    ],
                  );
                });
            await DepotLineRepository(context.read<StockBuddyBackend>())
                .updateLineDetails(
              row.id,
              note.text,
              lineItemUpdateController.getTags(),
              lineItemUpdateController.activeState,
            );
            _source.reloadCurrentView();
          },
          cells: [
            DataCell(
              Text(
                row.isin,
              ),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: row.isin));
                context.showSnackBar(message: 'ISIN in clipboard');
              },
            ),
            CellHelper.textCell(row.name),
            DataCell(
              Wrap(
                children: [
                  ...row.tags?.map((e) => Chip(label: Text(e))).toList() ??
                      [const Text('')]
                ],
              ),
            ),
            CellHelper.textCell(note),
            CellHelper.number(
              row.lastTotalValue,
              decoration: '€',
              context: context,
            ),
            CellHelper.number(
              row.lastWinLoss,
              decoration: '€',
              context: context,
            ),
            CellHelper.number(
              row.lastWinLossPercent,
              decoration: '%',
              context: context,
            )
          ],
        );
      },
    );
  }

  void setSort(int i, bool asc) => setState(() {
        _sortIndex = i;
        _sortAsc = asc;
      });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: showActiveOnly
                      ? 'Currently showing only active'
                      : 'Currently showing all',
                  onPressed: () {
                    setState(() {
                      showActiveOnly = !showActiveOnly;
                    });

                    _source.applyServerSideFilter(
                        _searchController.text, showActiveOnly);
                  },
                  icon: Icon(showActiveOnly
                      ? Icons.monetization_on_rounded
                      : Icons.monetization_on_outlined),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by ISIN/tag',
                      ),
                      onSubmitted: (vlaue) {
                        _source.applyServerSideFilter(
                          _searchController.text,
                          showActiveOnly,
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.text = '';
                    });
                    _source.applyServerSideFilter(
                      _searchController.text,
                      showActiveOnly,
                    );
                  },
                  icon: const Icon(Icons.clear),
                ),
                IconButton(
                  onPressed: () => _source.applyServerSideFilter(
                    _searchController.text,
                    showActiveOnly,
                  ),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Positioned(
            top: 55,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            child: SingleChildScrollView(
              child: SizedBox(
                width: size.width,
                child: AdvancedPaginatedDataTable(
                  addEmptyRows: false,
                  source: _source,
                  showHorizontalScrollbarAlways: true,
                  sortAscending: _sortAsc,
                  sortColumnIndex: _sortIndex,
                  showFirstLastButtons: true,
                  rowsPerPage: _rowsPerPage,
                  showCheckboxColumn: false,
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
                      onSort: setSort,
                    ),
                    DataColumn(
                      label: const Text('Name'),
                      onSort: setSort,
                    ),
                    DataColumn(
                      label: const Text('Tags'),
                      onSort: setSort,
                    ),
                    DataColumn(
                      label: const Text('Note'),
                      onSort: setSort,
                    ),
                    DataColumn(
                      label: const Text('Total invest'),
                      onSort: setSort,
                      numeric: true,
                    ),
                    DataColumn(
                      label: const Text('Win/Loss €'),
                      onSort: setSort,
                      numeric: true,
                    ),
                    DataColumn(
                      label: const Text('Win/Loss %'),
                      onSort: setSort,
                      numeric: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
