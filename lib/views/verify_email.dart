import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

class VerifyEmailView extends StatelessWidget {
  VerifyEmailView({super.key});

  final user = FirebaseAuth.instance.currentUser;

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
      body: Column(
        children: [
          const SizedBox(height: 150),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Tap the button below to send a verification link to your E-mail address.",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            onPressed: () async {
              await user?.sendEmailVerification();
            },
            child: const Text("Get Verification Link"),
          ),
        ],
      ),
    );
  }
}
