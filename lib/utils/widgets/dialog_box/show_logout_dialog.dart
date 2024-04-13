import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      icon: const Icon(Icons.logout),
      content: 'Are you sure you want to logout?',
      options: {
        'Yes': true,
        'No': false,
      }).then((value) => value ?? false);
}
