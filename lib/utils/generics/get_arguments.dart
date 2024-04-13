import 'package:flutter/material.dart';

extension GetArguments on BuildContext {
  T? getArguments<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args != null) {
      return args as T;
    }
    return null;
  }
}
