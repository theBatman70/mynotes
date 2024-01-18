import 'package:flutter/material.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialog_box/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Center(child: Text("Hello!")),
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
                      const InputDecoration(hintText: 'Enter your e-mail ID'),
                ),
                TextField(
                  controller: _password,
                  decoration:
                      const InputDecoration(hintText: 'Create a New Password'),
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                ),
                TextButton(
                  child: const Text('Register'),
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      await AuthService.firebase()
                          .createUser(id: email, password: password);
                      await AuthService.firebase().sendEmailVerification();
                      if (!mounted) return;
                      Navigator.of(context).pushNamed(verifyRoute);
                    } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(
                          context, 'This email is already in use.');
                    } on InvalidEmailAuthException {
                      await showErrorDialog(
                          context, 'The given email is invalid. Please check.');
                    } on WeakPasswordAuthException {
                      await showErrorDialog(context, 'Weak password');
                    } catch (e) {
                      await showErrorDialog(context, e.toString());
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, ((route) => false));
                      },
                      child: const Text('Log In'),
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
