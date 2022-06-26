import 'package:flutter/material.dart';

class EditNotes extends StatefulWidget {
  final TextEditingController controller;
  final double? width;
  final double? height;
  const EditNotes(
      {required this.controller, this.width = 350, this.height = 350, Key? key})
      : super(key: key);

  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: widget.controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}
