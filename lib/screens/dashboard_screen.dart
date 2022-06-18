import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/export_repository.dart';
import 'package:stock_buddy/utils/snackbar_extension.dart';
import 'package:stock_buddy/widgets/export_overview_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final exportRepo = ExportRepositories();
  List<ExportRecord> _data = [];
  bool _dragging = false;
  bool _intialLoadDone = false;
  late final Future<void> _initialFuture;
  Future<void> _initialLoad() async {
    if (_intialLoadDone) {
      return;
    }
    _intialLoadDone = true;
    _data = await exportRepo.getAllExports();
  }

  @override
  void initState() {
    _initialFuture = _initialLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: DropTarget(
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
            FutureBuilder<void>(
              future: _initialFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_data.isEmpty) {
                    return Center(
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
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          final currentRow = _data[index];
                          return ExportOverviewListTile(
                            data: currentRow,
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
                                  await exportRepo.deleteExport(currentRow.id);
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                  _loadData();
                                },
                              );
                              // set up the AlertDialog
                              AlertDialog alert = AlertDialog(
                                title: const Text("Please confirm"),
                                content:
                                    const Text("The export will be deleted!"),
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
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickExportFile,
        child: const FaIcon(FontAwesomeIcons.plus),
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
    final result = await exportRepo.importNewData(
        path, () async => "Test"); //TODO ask user for actual name
    if (!mounted) return;
    Navigator.of(context).pop();

    if (result != null) {
      setState(() {
        _data.add(result);
        _data.sort(((a, b) => a.exportDate.compareTo(b.exportDate)));
      });
    } else {
      context.showErrorSnackBar(message: 'Unable to import this file');
    }
  }

  Future<void> _loadData() async {
    final newData = await exportRepo.getAllExports();
    setState(() {
      _data = newData;
    });
  }
}
