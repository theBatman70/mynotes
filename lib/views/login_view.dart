import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Login"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  const SizedBox(height: 150),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'Enter Your e-mail ID'),
                        ),
                        TextField(
                          controller: _password,
                          decoration: const InputDecoration(
                              hintText: 'Enter your password'),
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                        TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                              print(userCredential);
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                print('User not found.');
                              } else if (e.code == 'invalid-email') {
                                print(
                                    'The given email is invalid. Please check.');
                              } else if (e.code == 'wrong-password') {
                                print(
                                    'The password is wrong for the given account.');
                              } else if (e.code == 'user-disabled') {
                                print('Sorry, the user has been disabled.');
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            default:
              return const Text('Loading... /nPlease check your network');
          }
        },
      ),
    );
  }
}
