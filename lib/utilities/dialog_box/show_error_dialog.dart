import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog_box/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String content,
) {
  return showGenericDialog(
      context: context,
      title: 'An Error Occured',
      content: content,
      options: {'OK': Null});
}
