import 'package:flutter/material.dart';
import 'package:stock_buddy/models/deopt_item.dart';
import 'package:stock_buddy/widgets/edit_notes.dart';

typedef GetTagList = List<String> Function();

class TagController {
  late final GetTagList getTags;
}

class DepotLineUpdate extends StatefulWidget {
  final DepotItem data;
  final TextEditingController controller;
  final TagController tagController;

  const DepotLineUpdate(
      {required this.controller,
      required this.data,
      required this.tagController,
      Key? key})
      : super(key: key);

  @override
  State<DepotLineUpdate> createState() => _DepotLineUpdateState();
}

class _DepotLineUpdateState extends State<DepotLineUpdate> {
  List<String> tags = [];
  final tagControll = TextEditingController();
  @override
  void initState() {
    super.initState();

    widget.controller.text = widget.data.note ?? '';
    if (widget.data.tags != null) {
      tags.addAll(widget.data.tags!);
    }
    widget.tagController.getTags = () => tags;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Note'),
        const Padding(padding: EdgeInsets.only(top: 10)),
        EditNotes(
          controller: widget.controller,
          height: null,
          width: null,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text('Tages'),
        ),
        TextField(
          controller: tagControll,
          onSubmitted: (value) {
            final newTags = value.split(',');
            newTags.removeWhere((newTag) => tags.any(
                (extTage) => extTage.toLowerCase() == newTag.toLowerCase()));
            if (newTags.isNotEmpty) {
              setState(() {
                tags.addAll(newTags);
              });
            }
            tagControll.text = "";
          },
          decoration: const InputDecoration(
              hintText: 'New tag, multiple seperated by comma'),
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        Wrap(
          children: [
            ...tags.map(
              (e) => Chip(
                label: Text(e),
                onDeleted: () {
                  setState(() {
                    tags.remove(e);
                  });
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
