import 'package:flutter/material.dart';

class EditNotes extends StatefulWidget {
  final TextEditingController controller;
  const EditNotes({required this.controller, Key? key}) : super(key: key);

  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 350,
      child: TextFormField(
        controller: widget.controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}
