import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/repository/export_repository.dart';
import 'package:stock_buddy/utils/duplicate_export_exception.dart';
import 'package:stock_buddy/utils/snackbar_extension.dart';
import 'package:stock_buddy/widgets/depot_overview_tile.dart';
import 'package:stock_buddy/widgets/dropdown_confirm.dart';
import 'package:stock_buddy/widgets/text_confirm.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DataDepot> _data = [];

  late final Future<void> _initialLoad;
  late final DepotRepository _repo;
  var _firstLoad = true;
  var _dragging = false;

  @override
  void initState() {
    super.initState();
    _repo = DepotRepository(context.read<StockBuddyBackend>());
    _initialLoad = _loadData();
  }

  Future<void> _loadData() async {
    _data = await _repo.getAllDepots();
    if (_firstLoad) {
      _firstLoad = false;
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            return DropTarget(
              onDragDone: (detail) {
                if (detail.files.isNotEmpty) {
                  _addNewExport(detail.files.first.path);
                }
              },
              onDragEntered: (detail) {
                setState(() {
                  _dragging = true;
                });
              },
              onDragExited: (detail) {
                setState(() {
                  _dragging = false;
                });
              },
              child: Stack(
                children: [
                  if (_data.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircleAvatar(
                            radius: 60,
                            child: FaIcon(
                              FontAwesomeIcons.piggyBank,
                              size: 60,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text('No data found')
                        ],
                      ),
                    ),
                  if (_data.isNotEmpty)
                    RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            final currentRow = _data[index];
                            return DepotOverviewTile(
                              row: currentRow,
                              onDelteCallback: () {
                                // set up the buttons
                                Widget cancelButton = TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                                Widget continueButton = TextButton(
                                  child: const Text("Delete"),
                                  onPressed: () async {
                                    await _repo.deleteDepot(currentRow.id);
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    _loadData();
                                  },
                                );
                                // set up the AlertDialog
                                AlertDialog alert = AlertDialog(
                                  title: const Text("Please confirm"),
                                  content: const Text(
                                      "The depot and ALL related data will be DELETED!"),
                                  actions: [
                                    cancelButton,
                                    continueButton,
                                  ],
                                );
                                // show the dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );
                              },
                            );
                          }),
                    ),
                  if (_dragging)
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox.square(
                        dimension: 250,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                  radius: 60,
                                  child: FaIcon(
                                    FontAwesomeIcons.plus,
                                    size: 60,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Drop file here')
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickExportFile,
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 69, 99, 123),
              ),
              child: Text('Stock buddy'),
            ),
            ListTile(
              title: const Text('Version 0.0.2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExportFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      _addNewExport(result.files.single.path!);
    }
  }

  Future<void> _addNewExport(String path) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });

    try {
      final result = await ExportRepositories(context.read<StockBuddyBackend>())
          .importNewData(
        path,
        () {
          return showTextConfirm(context, 'New depot?',
              inputPlacholder: 'Enter depot name',
              addtionalText:
                  'Looks like this is a new depot, please provide a name');
        },
        () async {
          final value = await showDropdownConfirm<String>(
              context, _getDepotNameDropdown(), 'Select depot for dividends');
          return value ?? "";
        },
      );

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _loadData();
      context.showSnackBar(
          message: "Added $result new records based on the export file");
    } on DuplicateExportException {
      context.showErrorSnackBar(message: 'This export is already imported');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (ex) {
      context.showErrorSnackBar(
          message: 'Something went wrong importing the file');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<List<DropdownMenuItem<String>>> _getDepotNameDropdown() async {
    final repo = DepotRepository(context.read<StockBuddyBackend>());
    final repos = await repo.getAllDepots();
    return repos
        .map((e) => DropdownMenuItem<String>(
              value: e.id,
              child: Text(e.name),
            ))
        .toList();
  }
}
