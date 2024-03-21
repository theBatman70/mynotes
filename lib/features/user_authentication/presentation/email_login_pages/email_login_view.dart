import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/utilities/const/measurements.dart';
import 'package:mynotes/utilities/widgets/custom_poppins_button.dart';
import 'package:mynotes/utilities/widgets/dialog_box/show_error_dialog.dart';

import '../../bloc/auth_bloc.dart';

class EmailLoginView extends StatefulWidget {
  const EmailLoginView({super.key});

  @override
  State<EmailLoginView> createState() => _EmailLoginViewState();
}

class _EmailLoginViewState extends State<EmailLoginView> {
  late TextEditingController _email;
  late TextEditingController _password;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.sizeOf(context).height;
    var screenWidth = MediaQuery.sizeOf(context).width;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showErrorDialog(context, state.message);
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.teal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    top: screenWidth * 0.15,
                  ),
                  child: IconButton(
                      iconSize: 30,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.amberAccent,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: Center(
                    child: Text(
                      'Log In',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 26),
                      ),
                    ),
                  ),
                ),
                Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        color: Colors.white),
                    height: screenHeight * 0.65,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // const SizedBox(height: verticalTFSpacing),
                            TextFormField(
                              controller: _email,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                hintText: 'Enter your e-mail address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => validateEmail(value),
                            ),
                            const SizedBox(height: verticalTFSpacing),
                            TextFormField(
                              controller: _password,
                              autocorrect: false,
                              enableSuggestions: false,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  hintText: 'Password'),
                            ),
                            // const SizedBox(height: verticalTFSpacing),
                            const SizedBox(height: 50),
                            CustomPoppinsButton(
                                buttonText: 'Confirm',
                                onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      final email = _email.text;
                                      final password = _password.text;
                                      context
                                          .read<AuthBloc>()
                                          .add(LoginWithEmail(email, password));
                                    }
                                }),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't Have an Account?"),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(emailRegisterRoute);
                                    },
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                          color: CupertinoColors.systemBlue),
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email ID required';
  }
  if (!RegExp(r'^\S+@\S+\.\S+').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null; // Return null if validation passes.
}
