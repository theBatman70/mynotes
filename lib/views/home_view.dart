import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialog_box/show_logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

import '../services/crud/models/database_note.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {
                        final shouldLogout = await showLogoutDialog(context);
                        if (shouldLogout) {
                          if (mounted) {
                            AuthService.firebase().logOut();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute, (route) => false);
                          }
                        }
                      },
                      child: const Text('Log out'),
                    ),
                  ]),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                            "Go create a note! \n\nAll your notes will be shown here."),
                      );
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          allNotes: allNotes,
                          onDeleteNote: (note) {
                            _notesService.deleteNote(noteId: note.noteId);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(newNoteRoute);
          },
        ),
      ),
    );
  }
}
