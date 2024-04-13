import 'package:flutter/material.dart';

typedef DialogOptions<T> = Map<String, T?>;

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required Widget icon,
  required String content,
  required DialogOptions options,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: icon,
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      actions: options.keys.map((option) {
        final value = options[option];
        return TextButton(
          onPressed: () {
            if (value != null) {
              Navigator.of(context).pop(value);
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(option),
        );
      }).toList(),
    ),
  );
}
