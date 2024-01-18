import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  var user = AuthService.firebase().currentUser;

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, ((route) => false));
          },
        ),
        centerTitle: true,
        title: const Text("Verify Your Email."),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 100),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Please check your e-mail for the verification link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                },
                child: const Text("Send Again"),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('If you have verified your e-mail, you can proceed.'),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () async {
                    user = AuthService.firebase().currentUser;
                    logger.i(user);
                    logger.i(user!.isEmailVerified);
                    if (mounted) {
                      if (user?.isEmailVerified == true) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(const Duration(seconds: 3), () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  loginRoute, (route) => false);
                            });
                            return const AlertDialog(
                              title: Icon(Icons.check_circle),
                              content: Text(
                                'Email is Verified, /n Redirecting you to Login Page',
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Icon(Icons.error),
                              content: const Text('Email is not yet verified.'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'))
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Text('Proceed')),
            ],
          ),
        ],
      ),
    );
  }
}
