import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialog_box.dart';
import 'package:logger/logger.dart';

final logger = Logger();

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
                      final userCredential = await AuthService.firebase()
                          .logIn(id: email, password: password);
                      if (!mounted) return;
                      logger.i(userCredential.toString());
                      final user = AuthService.firebase().currentUser;
                      if (user?.isEmailVerified ?? false) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            homeRoute, (route) => false);
                      } else {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            verifyRoute, (route) => false);
                      }
                    } on UserNotFoundAuthException {
                      await showErrorDialog(context, 'User not found.');
                    } on InvalidEmailAuthException {
                      await showErrorDialog(
                          context, 'The given email is invalid. Please check.');
                    } on WrongPasswordAuthException {
                      await showErrorDialog(context,
                          'The password is incorrect for the given account.');
                    } on UserDisabledAuthException {
                      await showErrorDialog(
                          context, 'Sorry, the user has been disabled.');
                    } catch (e) {
                      await showErrorDialog(context, e.toString());
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
