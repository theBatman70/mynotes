import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String content,
) {
  return showGenericDialog(
      context: context,
      title: 'An Error Occurred',
      content: content,
      options: {'OK': null});
}
