import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NotesViewList extends StatelessWidget {
  final List<DatabaseNote> notes;

  const NotesViewList({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
