import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/utils/widgets/custom_poppins_button.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  late Timer _timer;
  int _secondsLeft = 120;

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (_secondsLeft < 1) {
            timer.cancel();
            context.read<AuthBloc>().add(const CancelEmailVerification());
            _secondsLeft = 120; // Reset the time for another start
          } else {
            _secondsLeft = _secondsLeft - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Verify Your Email."),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthStateLoggedIn) {
            _timer.cancel();
            // Navigator.pop(context);
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 65),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                width: 280,
                child: const Text.rich(
                  TextSpan(
                      text: "Please check your ",
                      style: TextStyle(fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(
                            text: "E-MAIL",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        TextSpan(text: " for the "),
                        TextSpan(
                            text: "verification link",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  width: 280,
                  child: const Text.rich(
                      textAlign: TextAlign.right,
                      TextSpan(
                          text: "You'll be ",
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                                text: "LOGGED IN",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            TextSpan(text: " right after the verification.")
                          ]))),
            ),
            const SizedBox(
              height: 40,
            ),
            _timer.isActive
                ? Text.rich(TextSpan(
                    text: _secondsLeft.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    children: const [
                        TextSpan(text: ' s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black))
                      ]))
                : SizedBox(
                    width: 225,
                    child: CustomPoppinsButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const SendUserEmailVerification());
                        startTimer();
                      },
                      buttonText: 'Send Again',
                      icon: Icons.restart_alt,
                    )),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 140,
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(const CancelEmailVerification());
            context.read<AuthBloc>().add(const AuthEventLogout());
            Navigator.of(context).pushNamed(signInRoute);
          },
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.cancel),
                Text(
                  'Log out',
                  style: TextStyle(fontSize: 18),
                )
              ]),
        ),
      ),
    );
  }
}
