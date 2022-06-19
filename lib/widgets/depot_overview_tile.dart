import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_buddy/models/database_depot.dart';
import 'package:stock_buddy/utils/text_helper.dart';

class DepotOverviewTile extends StatelessWidget {
  final DataDepot row;
  final VoidCallback onDelteCallback;
  const DepotOverviewTile(
      {required this.row, required this.onDelteCallback, Key? key})
      : super(key: key);

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
      endActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        dragDismissible: false,

        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (_) {
              context.goNamed(
                'reporting_overview',
                params: {
                  'depotNumber': row.id,
                },
              );
            },
            backgroundColor: Colors.green,
            icon: Icons.area_chart_outlined,
            label: 'Report',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: ListTile(
        leading: row.totalGainLoss.isNegative
            ? const FaIcon(
                FontAwesomeIcons.arrowTrendDown,
                color: Colors.red,
              )
            : const FaIcon(
                FontAwesomeIcons.arrowTrendUp,
                color: Colors.green,
              ),
        title: Text(row.name),
        subtitle: Text('Number: ${row.number} Exports: ${row.totalExports}'),
        trailing: TextHelper.number(
          row.totalGainLoss,
          context: context,
        ),
        onTap: () {
          context.goNamed(
            'export_overview',
            params: {
              'depotNumber': row.id,
            },
          );
        },
      ),
    );
  }
}
