import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/dialog_box.dart';
import 'dart:developer' show log;

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
      body: Column(
        children: [
          const SizedBox(height: 150),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'Enter Your e-mail ID'),
                ),
                TextField(
                  controller: _password,
                  decoration:
                      const InputDecoration(hintText: 'Enter your password'),
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
                      log(userCredential.toString());
                      final user = FirebaseAuth.instance.currentUser;
                      if (user?.emailVerified == true) {
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              homeRoute, (route) => false);
                        }
                      } else {
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyRoute, (route) => false);
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      if (mounted) {
                        if (e.code == 'user-not-found') {
                          await showErrorDialog(context, 'User not found.');
                        } else if (e.code == 'invalid-email') {
                          await showErrorDialog(context,
                              'The given email is invalid. Please check.');
                        } else if (e.code == 'wrong-password') {
                          await showErrorDialog(context,
                              'The password is incorrect for the given account.');
                        } else if (e.code == 'user-disabled') {
                          await showErrorDialog(
                              context, 'Sorry, the user has been disabled.');
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        await showErrorDialog(context, e.toString());
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not registered yet?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, ((route) => false));
                      },
                      child: const Text('Register'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
