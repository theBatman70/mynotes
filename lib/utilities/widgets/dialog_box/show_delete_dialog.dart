import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'Delete note',
      content: 'Are you sure you want to delete selected note(s) ?',
      options: {'Yes': true, 'No': false}).then((value) => value ?? false);
}
