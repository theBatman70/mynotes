import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/providers/selection_mode.dart';
import 'package:mynotes/presentation/notes_view/notes_view.dart';
import 'package:mynotes/presentation/notes_view/create_update_note_view.dart';
import 'package:mynotes/presentation/sign_in_view/login_view.dart';
import 'package:mynotes/presentation/sign_in_view/register_view.dart';
import 'package:mynotes/presentation/sign_in_view/verify_email.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyApp(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyRoute: (context) => const VerifyEmailView(),
        homeRoute: (context) => const NotesView(),
        createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final currentUser = FirebaseAuth.instance.currentUser;
            logger.i(currentUser);
            if (currentUser == null) {
              return const RegisterView();
            } else if (currentUser.emailVerified) {
              return ChangeNotifierProvider(
                  create: (context) => SelectionModeModel(),
                  child: const NotesView());
            } else {
              return const VerifyEmailView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
