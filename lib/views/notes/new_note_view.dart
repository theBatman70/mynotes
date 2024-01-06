import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

import '../../services/crud/models/database_note.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  @override
  void initState() {
    _notesService = NotesService();
    _titleTextEditingController = TextEditingController();
    _noteTextEditingController = TextEditingController();
    super.initState();
  }

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _noteTextEditingController;

  void _titleTextControllerListener() {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleTextEditingController.text;
    _notesService.updateNote(note: note, title: title, text: note.text);
  }

  void _noteTextControllerListener() {
    final note = _note;
    if (note == null) {
      return;
    }
    final noteText = _noteTextEditingController.text;
    _notesService.updateNote(note: note, title: note.title, text: noteText);
  }

  void _setupTextControllerListener() {
    _noteTextEditingController.removeListener(_noteTextControllerListener);
    _noteTextEditingController.addListener(_noteTextControllerListener);

    _titleTextEditingController.removeListener(_titleTextControllerListener);
    _titleTextEditingController.addListener(_titleTextControllerListener);
  }

  // Create a blank new note
  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final note = await _notesService.createNote(owner: owner);
    return note;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;

    if (_isNoteEmpty() && note != null) {
      _notesService.deleteNote(noteIDs: [note.noteId]);
    }
  }

  bool _isNoteEmpty() {
    final title = _titleTextEditingController.text;
    final noteText = _noteTextEditingController.text;
    if (title.isEmpty && noteText.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _titleTextEditingController.text;
    final noteText = _noteTextEditingController.text;

    if (!_isNoteEmpty() && note != null) {
      await _notesService.updateNote(note: note, title: title, text: noteText);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _titleTextEditingController.dispose();
    _noteTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsetsDirectional.only(start: 30, end: 10),
                    child: TextField(
                      controller: _titleTextEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Title",
                        hintStyle: TextStyle(fontSize: 25, color: Colors.black),
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsetsDirectional.only(start: 30, end: 10),
                    child: TextField(
                      controller: _noteTextEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: "Note",
                          hintStyle: TextStyle(fontSize: 19),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none),
                    ),
                  ),
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
