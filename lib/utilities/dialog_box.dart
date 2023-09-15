import "package:flutter/material.dart";

Future<void> showErrorDialog(context, String text) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('An Error Occured'),
      content: Text(text),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'))
      ],
    ),
  );
}
