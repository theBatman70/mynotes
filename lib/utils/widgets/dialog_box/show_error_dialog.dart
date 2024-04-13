import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String content,
) {
  return showGenericDialog(
      context: context,
      icon: const Icon(Icons.error),
      content: content,
      options: {'OK': null});
}
