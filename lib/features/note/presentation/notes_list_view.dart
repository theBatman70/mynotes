import 'package:flutter/material.dart';
import 'package:mynotes/features/note/providers/selection_mode.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import 'package:mynotes/services/crud/models/database_note.dart';

typedef NoteCallBack = void Function(DatabaseNote note);

class NotesListView extends StatefulWidget {
  final List<DatabaseNote> allNotes;
  final NoteCallBack onTap;

  const NotesListView({
    super.key,
    required this.allNotes,
    required this.onTap,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      itemCount: widget.allNotes.length,
      itemBuilder: (context, index) {
        final length = widget.allNotes.length;
        final note = widget.allNotes[length - index - 1];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Consumer<SelectionMode>(
            builder:
                (BuildContext context, SelectionMode selectionState, Widget? child) {
              return ListTile(
                title: note.title != ''
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(note.title,
                          maxLines: 3,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium),
                    )
                    : null,
                subtitle: Text(
                  note.text,
                  softWrap: true,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style:
                      Theme.of(context).textTheme.bodySmall,
                ),
                tileColor: Colors.grey[400],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                selectedTileColor: Colors.amber.shade100,
                selected: selectionState.selectionMode
                    ? selectionState.isSelected(note.noteId)
                    : false,
                onLongPress: () {
                  !selectionState.selectionMode
                      ? selectionState.turnOnSelectionMode()
                      : null;
                  selectionState.toggleSelection(note.noteId);
                },
                onTap: () {
                  if (selectionState.selectionMode) {
                    selectionState.toggleSelection(note.noteId);
                  } else {
                    widget.onTap(note);
                  }
                },
              );
            },
          ),
        );
      },
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );
  }
}
