import 'package:flutter/material.dart';

Future<String> showTextConfirm(BuildContext context, String title,
    {String? inputPlacholder, String? addtionalText}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (addtionalText != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Text(
                    addtionalText,
                  ),
                ),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: inputPlacholder,
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: (() {
                Navigator.pop(context, controller.text);
              }),
              child: const Text('OK'),
            ),
          ],
        );
      });

  return result ?? '';
}
