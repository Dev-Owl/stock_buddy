import 'package:flutter/material.dart';

Future<T?> showDropdownConfirm<T>(
  BuildContext context,
  Future<List<DropdownMenuItem<T>>> loadData,
  String tilte, {
  String? addtionalText,
}) {
  T? selectedValue;
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(tilte),
        content: FutureBuilder<List<DropdownMenuItem<T>>>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Please wait'),
                  Padding(
                      padding: EdgeInsets.symmetric(
                    vertical: 5,
                  )),
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              );
            }
            if (snapshot.data?.isEmpty == true) {
              return const Text('No data was found, unable to select a value');
            }

            return StatefulBuilder(
              builder: (context, setState) {
                selectedValue ??= snapshot.data!.first.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (addtionalText != null) Text(addtionalText),
                    DropdownButton<T>(
                      items: snapshot.data!,
                      value: selectedValue,
                      onChanged: (value) {
                        setState(
                          () => selectedValue = value,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: (() {
              Navigator.pop(context, null);
            }),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: (() {
              Navigator.pop(context, selectedValue);
            }),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
