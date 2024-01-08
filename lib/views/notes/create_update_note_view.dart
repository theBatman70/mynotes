import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

import '../../services/crud/models/database_note.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  @override
  void initState() {
    _notesService = NotesService();
    _titleTextEditingController = TextEditingController();
    _noteTextEditingController = TextEditingController();
    super.initState();
  }

  late final DatabaseNote _note;
  late final NotesService _notesService;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _noteTextEditingController;
  late final String title;

  void _titleTextControllerListener() {
    final note = _note;
    final title = _titleTextEditingController.text;
    _notesService.updateNote(note: note, title: title, text: note.text);
  }

  void _noteTextControllerListener() {
    final note = _note;
    final noteText = _noteTextEditingController.text;
    _notesService.updateNote(note: note, title: note.title, text: noteText);
  }

  void _setupTextControllerListener() {
    _noteTextEditingController.removeListener(_noteTextControllerListener);
    _noteTextEditingController.addListener(_noteTextControllerListener);

    _titleTextEditingController.removeListener(_titleTextControllerListener);
    _titleTextEditingController.addListener(_titleTextControllerListener);
  }

  // If Existing note update self, else Create a blank new note
  Future<DatabaseNote> createOrUpdateNote(BuildContext context) async {
    final existingNote = context.getArguments<DatabaseNote>();
    if (existingNote != null) {
      _note = existingNote;
      _noteTextEditingController.text = existingNote.text;
      _titleTextEditingController.text = existingNote.title;
      return _note;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final note = await _notesService.createNote(owner: owner);
    _note = note;
    return _note;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;

    if (_isNoteEmpty()) {
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

    if (!_isNoteEmpty()) {
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
        title: Text(context.getArguments() != null ? '' : 'New Note'),
      ),
      body: FutureBuilder(
        future: createOrUpdateNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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
