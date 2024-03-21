import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/features/note/providers/selection_mode.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/features/note/presentation/notes_list_view.dart';
import 'package:mynotes/utilities/widgets/dialog_box/show_delete_dialog.dart';
import 'package:mynotes/utilities/widgets/dialog_box/show_logout_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:mynotes/services/crud/models/database_note.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state as AuthStateLoggedIn;
    final currentAppUser = state.user;
    return Scaffold(
      appBar: AppBar(
          title: const Text('My Notes', style: TextStyle(fontSize: 26),),
          centerTitle: true,
          leading: DrawerButton(
            onPressed: () {
              const Drawer();
            },
          ),
          actions: [
            Consumer<SelectionMode>(builder: (context, provider, child) {
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
                bool shouldLogout = false;
                return BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    shouldLogout
                        ? context.read<AuthBloc>().add(const AuthEventLogout())
                        : null;
                  },
                  child: PopupMenuButton(
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () async {
                                shouldLogout = await showLogoutDialog(context);
                              },
                              child: const Text('Log out'),
                            ),
                          ]),
                );
              }
            })
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: FutureBuilder(
          future: _notesService.getOrCreateUser(id: currentAppUser.id),
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
        width: 75,
        margin: const EdgeInsetsDirectional.all(20),
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(createUpdateNoteRoute);
          },
        ),
      ),
    );
  }
}
