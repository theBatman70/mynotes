import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog_box/show_delete_dialog.dart';

import '../../services/crud/models/database_note.dart';

typedef DeleteNoteCallBack = void Function(DatabaseNote note);

class NotesListView extends StatefulWidget {
  final List<DatabaseNote> allNotes;
  final DeleteNoteCallBack onDeleteNote;

  const NotesListView({
    super.key,
    required this.allNotes,
    required this.onDeleteNote,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.allNotes.length,
      itemBuilder: (context, index) {
        final note = widget.allNotes[index];
        return Dismissible(
          key: Key(note.noteId.toString()),
          onDismissed: (direction) async {
            final shouldDelete = await showDeleteDialog(context);
            shouldDelete
                ? widget.onDeleteNote(note)
                : widget.allNotes.insert(index, note);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: ListTile(
              title: Text(
                note.title,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                note.text,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              tileColor: Colors.grey,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
    );
  }
}
