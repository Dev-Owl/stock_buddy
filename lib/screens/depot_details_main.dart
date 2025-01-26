import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/repository/depot_repository.dart';
import 'package:stock_buddy/widgets/edit_notes.dart';

class DepotDetailsMain extends StatefulWidget {
  final String depotId;

  const DepotDetailsMain({
    required this.depotId,
    super.key,
  });

  @override
  State<DepotDetailsMain> createState() => _DepotDetailsMainState();
}

class _DepotDetailsMainState extends State<DepotDetailsMain> {
  final textController = TextEditingController();

  DataDepot? data;
  late final Future<void> _initalLoad;
  @override
  void initState() {
    super.initState();
    _initalLoad = _loadData(
      callSetState: false,
    );
  }

  Future<void> _loadData({bool callSetState = true}) async {
    final repo = DepotRepository(context.read<StockBuddyBackend>());
    data = (await repo.getAllDepots(filterById: widget.depotId)).first;
    textController.text = data?.notes ?? "";
    if (callSetState) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _initalLoad,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.done) {
            return _content();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        ListTile(
          title: const Text('OVERVIEW'),
          subtitle: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                '''Number of exports: ${data!.totalExports}
Last export date: ${data!.lastExportTime} ''',
              ),
            ),
          ),
        ),
        ListTile(
          isThreeLine: true,
          title: const Text('DEPOT NOTES'),
          subtitle: EditNotes(
            controller: textController,
            width: null,
            height: null,
          ),
          trailing: TextButton(
            child: const Text('SAVE'),
            onPressed: () {
              DepotRepository(context.read<StockBuddyBackend>())
                  .updateDepotNotes(widget.depotId, textController.text)
                  .then((value) => _loadData())
                  .then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Note saved',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  );
            },
          ),
        ),
        ListTile(
          title: const Text('DANGER ZONE'),
          subtitle: Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              label: const Text('Delete depot'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (c) {
                      return AlertDialog(
                        title: const Text('Please confirm'),
                        content:
                            const Text('ALL related data will be DELETED!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                            },
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final repo = DepotRepository(
                                  context.read<StockBuddyBackend>());
                              final currentRev =
                                  await repo.getCurrentRevById(widget.depotId);
                              repo.deleteDepot(widget.depotId, currentRev).then(
                                (value) {
                                  Navigator.pop(c);
                                  Navigator.pop(context, true);
                                },
                              );
                            },
                            child: const Text('CONFIRM'),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.delete),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red //elevated btton background color
                  ),
            ),
          ),
        )
      ],
    );
  }
}
