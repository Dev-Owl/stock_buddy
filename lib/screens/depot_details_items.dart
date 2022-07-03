import 'dart:math';

import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/repository/depot_line_repository.dart';
import 'package:stock_buddy/utils/data_cell_helper.dart';
import 'package:stock_buddy/widgets/depot_detail_line.dart';

class DepotDetailsLineItems extends StatefulWidget {
  final String depotId;
  const DepotDetailsLineItems({required this.depotId, Key? key})
      : super(key: key);

  @override
  State<DepotDetailsLineItems> createState() => _DepotDetailsLineItemsState();
}

class _DepotDetailsLineItemsState extends State<DepotDetailsLineItems> {
  final _searchController = TextEditingController();
  late final DepotLineItemsDataSource _source;
  var _sortIndex = 0;
  var _sortAsc = true;
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _source = DepotLineItemsDataSource(
      depotId: widget.depotId,
      getRowCallback: (DepotItem row) {
        var note = row.note?.substring(0, min(row.note?.length ?? 0, 30)) ?? '';
        if (note.isNotEmpty) {
          note = "$note...";
        }
        return DataRow(
          onSelectChanged: (value) async {
            final note = TextEditingController(
              text: row.note,
            );
            final tags = TagController();
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
                        tagController: tags,
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
            await DepotLineRepository()
                .updateLineDetails(row.id, note.text, tags.getTags());
            _source.reloadCurrentView();
          },
          cells: [
            CellHelper.textCell(row.isin),
            CellHelper.textCell(row.name),
            DataCell(Wrap(
              children: [
                ...row.tags?.map((e) => Chip(label: Text(e))).toList() ??
                    [const Text('')]
              ],
            )),
            CellHelper.textCell(note),
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
    return Scaffold(
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
                        labelText: 'Search by ISIN/tag',
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
            height: MediaQuery.of(context).size.height - 150,
            child: SingleChildScrollView(
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
                    numeric: false,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
