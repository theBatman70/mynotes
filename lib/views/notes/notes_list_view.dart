import 'package:flutter/material.dart';
import 'package:mynotes/providers/selection_mode.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../services/crud/models/database_note.dart';

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
          child: Consumer<SelectionModeModel>(
            builder: (BuildContext context, SelectionModeModel provider,
                Widget? child) {
              return ListTile(
                title: note.title != ''
                    ? Text(
                        note.title,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                subtitle: Text(
                  note.text,
                  softWrap: true,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                tileColor: Colors.grey.shade500,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                selectedTileColor: Colors.amber.shade100,
                selected: provider.selectionMode
                    ? provider.isSelected(note.noteId)
                    : false,
                onLongPress: () {
                  !provider.selectionMode
                      ? provider.turnOnSelectionMode()
                      : null;
                  provider.toggleSelection(note.noteId);
                },
                onTap: () {
                  if (provider.selectionMode) {
                    provider.toggleSelection(note.noteId);
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
