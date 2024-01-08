import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/providers/selection_mode.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialog_box/show_delete_dialog.dart';
import 'package:mynotes/utilities/dialog_box/show_logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
import 'package:provider/provider.dart';

import '../../services/crud/models/database_note.dart';

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
          leading: DrawerButton(
            onPressed: () {
              const Drawer();
            },
          ),
          actions: [
            Consumer<SelectionModeModel>(builder: (context, provider, child) {
              if (provider.selectionMode) {
                return Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          final shouldDelete = await showDeleteDialog(context);
                          if (shouldDelete) {
                            await _notesService.deleteNote(
                                noteIDs: provider
                                    .selectedNoteIDs); // Delete in NotesService
                            provider.turnOffSelectionMode();
                          }
                        },
                        icon: const Icon(Icons.delete)),
                    IconButton(
                        onPressed: () {
                          provider.turnOffSelectionMode();
                        },
                        icon: const Icon(Icons.cancel)),
                  ],
                );
              } else {
                return PopupMenuButton(
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () async {
                              final shouldLogout =
                                  await showLogoutDialog(context);
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
                        ]);
              }
            })
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            allNotes: allNotes,
                            onTap: (DatabaseNote note) {
                              Navigator.of(context).pushNamed(
                                  createUpdateNoteRoute,
                                  arguments: note);
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
            Navigator.of(context).pushNamed(createUpdateNoteRoute);
          },
        ),
      ),
    );
  }
}
