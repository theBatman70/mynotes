import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/routes/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    bool verified = false;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(emailLoginRoute, ((route) => false));
          },
        ),
        centerTitle: true,
        title: const Text("Verify Your Email."),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          verified = state is AuthStateEmailVerified;
        },
        builder: (context, state) => verified
            ? const Center(
                child: AlertDialog(
                  title: Icon(Icons.check_circle),
                  content: Text(
                    'Email is Verified, \n Redirecting you to Login Page',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Row(
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
                          final state = context.read<AuthBloc>().state
                              as EmailNeedsVerification;
                          final user = state.emailAuthUser;
                          context
                              .read<AuthBloc>()
                              .add(SendUserEmailVerification(user));
                        },
                        child: const Text("Send Again"),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
