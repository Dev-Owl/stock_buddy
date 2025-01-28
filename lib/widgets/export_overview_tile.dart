import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stock_buddy/models/export_record.dart';
import 'package:stock_buddy/utils/text_helper.dart';

class ExportOverviewListTile extends StatelessWidget {
  final ExportRecord data;
  final VoidCallback onDelteCallback;
  final DateFormat format = DateFormat.yMMMMEEEEd();
  ExportOverviewListTile({
    required this.data,
    required this.onDelteCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: const ValueKey(0),

      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        dragDismissible: false,

        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (_) => onDelteCallback(),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: ListTile(
        title: Text('Total invest: ${data.totalSpent}€'),
        subtitle: Text("Export from ${format.format(data.exportTime)}"),
        trailing: TextHelper.number(
          data.winLossPercent,
          decoration: '%',
          context: context,
        ),
        onTap: () {
          context.goNamed(
            'export_details',
            pathParameters: {
              'exportId': data.id,
              'depotNumber': data.depotId,
            },
          );
        },
      ),
    );
  }
}
