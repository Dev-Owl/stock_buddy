import 'package:flutter/material.dart';

class ExportDetailScreen extends StatefulWidget {
  final String exportId;
  const ExportDetailScreen({required this.exportId, Key? key})
      : super(key: key);

  @override
  State<ExportDetailScreen> createState() => _ExportDetailScreenState();
}

class _ExportDetailScreenState extends State<ExportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Container(
        child: Text(widget.exportId),
      ),
    );
  }
}
