import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog_box/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      options: {'No': false, 'Yes': true}).then((value) => false);
}
