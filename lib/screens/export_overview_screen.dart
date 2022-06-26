import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/repository/export_repository.dart';
import 'package:stock_buddy/widgets/export_overview_tile.dart';

class ExportOverviewScreen extends StatefulWidget {
  final String depotId;
  const ExportOverviewScreen({required this.depotId, Key? key})
      : super(key: key);

  @override
  State<ExportOverviewScreen> createState() => _ExportOverviewScreennState();
}

class _ExportOverviewScreennState extends State<ExportOverviewScreen> {
  final exportRepo = ExportRepositories();
  List<ExportRecord> _data = [];
  bool _intialLoadDone = false;
  late final Future<void> _initialFuture;

  Future<void> _initialLoad() async {
    if (_intialLoadDone) {
      return;
    }
    _intialLoadDone = true;
    _data = await exportRepo.getAllExportsForDept(widget.depotId);
  }

  @override
  void initState() {
    _initialFuture = _initialLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                            content: const Text("The export will be deleted!"),
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
      ],
    );
  }

  Future<void> _loadData() async {
    final newData = await exportRepo.getAllExportsForDept(widget.depotId);
    setState(() {
      _data = newData;
    });
  }
}
