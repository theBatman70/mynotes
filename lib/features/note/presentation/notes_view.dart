import 'package:flutter/material.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/features/note/providers/selection_mode.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/features/note/presentation/notes_list_view.dart';
import 'package:mynotes/utils/widgets/dialog_box/show_delete_dialog.dart';
// import 'package:flutter_animate/flutter_animate.dart';

import 'package:mynotes/services/crud/models/database_note.dart';
import 'package:provider/provider.dart';

import '../../user_authentication/auth/users/app_user.dart';
import 'drawer_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  late final AppUser user;

  @override
  void initState() {
    super.initState();
    final AuthStateLoggedIn state =
        context.read<AuthBloc>().state as AuthStateLoggedIn;
    user = state.user;
    _notesService = NotesService();
    debugPrint('Notes View Build');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectionMode>(
      create: (context) => SelectionMode(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Notes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          actions: [
            Consumer<SelectionMode>(builder: (context, selectionState, child) {
              if (selectionState.selectionMode) {
                return Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          final shouldDelete = await showDeleteDialog(context);
                          if (shouldDelete) {
                            await _notesService.deleteNote(
                                noteIDs: selectionState
                                    .selectedNoteIDs); // Delete in NotesService
                            selectionState.turnOffSelectionMode();
                          }
                        },
                        icon: const Icon(Icons.delete)),
                    IconButton(
                        onPressed: () {
                          selectionState.turnOffSelectionMode();
                        },
                        icon: const Icon(Icons.cancel)),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            })
          ],
        ),
        drawer: const DrawerView(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: FutureBuilder(
            future: _notesService.getOrCreateUser(id: user.id),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as List<DatabaseNote>;
                            if (allNotes.isEmpty) {
                              return Container(
                                alignment: Alignment.center,
                                height: 200,
                                child: const Text.rich(
                                  textAlign: TextAlign.center,
                                  TextSpan(
                                      text:
                                          'Start adding your notes, and they will ',
                                      style: TextStyle(fontSize: 20),
                                      children: [
                                        TextSpan(
                                            text: 'appear here.',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500,
                                            ))
                                      ]),
                                ),
                              );
                            }
                            // Display the Notes List
                            return NotesListView(
                              allNotes: allNotes,
                              // On Tap of a Note inside the Notes List
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
      ),
    );
  }
}
