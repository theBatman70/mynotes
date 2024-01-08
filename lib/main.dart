import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/providers/selection_mode.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/sign_in_view/login_view.dart';
import 'package:mynotes/views/sign_in_view/register_view.dart';
import 'package:mynotes/views/sign_in_view/verify_email.dart';
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
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyRoute: (context) => const VerifyEmailView(),
        homeRoute: (context) => const HomeView(),
        createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  child: const HomeView());
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
