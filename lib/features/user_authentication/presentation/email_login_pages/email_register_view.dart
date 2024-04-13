// ignore_for_file: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/utils/widgets/custom_poppins_button.dart';
import 'package:mynotes/utils/widgets/dialog_box/show_error_dialog.dart';

class EmailRegisterView extends StatefulWidget {
  const EmailRegisterView({super.key});

  @override
  State<EmailRegisterView> createState() => _EmailRegisterViewState();
}

class _EmailRegisterViewState extends State<EmailRegisterView> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _reTypePassword;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _reTypePassword = TextEditingController();
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
        if (state is EmailNeedsVerification) {
          Navigator.of(context).pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Container(
              width: screenWidth,
              height: screenHeight,
              color: Colors.teal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      // Back Button
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        top: screenWidth * 0.15,
                      ),
                      child: const BackButton()),
                  Padding(
                    // Register a New Account
                    padding: const EdgeInsets.only(top: 10, left: 50),
                    child: Row(children: [
                      const Icon(
                        Icons.app_registration_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Register',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 26),
                        ),
                      ),
                    ]),
                  ),

                  // Form Layout with Curve Top
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        color: Colors.white),
                    height: screenHeight * 0.7,
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 90),
                    child: Column(
                      // Form Body (Column)
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: SizedBox(
                              height: 350,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: TextFormField(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          controller: _firstName,
                                          validator: (value) =>
                                              validateName(value),
                                          decoration: const InputDecoration(
                                              hintText: 'First Name',
                                              prefixIcon: Icon(
                                                  Icons.perm_identity_rounded)),
                                          keyboardType: TextInputType.name,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 170,
                                        child: TextFormField(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          controller: _lastName,
                                          validator: (value) =>
                                              validateName(value),
                                          // textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: 'Last Name',
                                          ),
                                          keyboardType: TextInputType.name,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: verticalTFSpacing),
                                  TextFormField(
                                    controller: _email,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.mail_outline),
                                      hintText: 'Enter your e-mail address',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: validateEmail,
                                  ),
                                  // const SizedBox(height: verticalTFSpacing),
                                  TextFormField(
                                    controller: _password,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.lock_outline),
                                        hintText: 'Set a password'),
                                    validator: validateIfEmpty,
                                  ),
                                  // const SizedBox(height: verticalTFSpacing),
                                  TextFormField(
                                    controller: _reTypePassword,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    obscureText: true,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.password),
                                        hintText: 'Re-type Password'),
                                    validator: validateRetypePassword,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Sign Up Button and Sign In Label
                        Column(
                          children: [
                            CustomPoppinsButton(
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                final firstName = _firstName.text;
                                final lastName = _lastName.text;
                                if (email.isEmpty &&
                                    password.isEmpty &&
                                    firstName.isEmpty &&
                                    lastName.isEmpty) {
                                  return;
                                }
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(CreateEmailUser(
                                      email, password, firstName, lastName));
                                }
                              },
                              buttonText: 'Sign Up',
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account?'),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              emailLoginRoute);
                                    },
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                          color: CupertinoColors.systemBlue),
                                    ))
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateRetypePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Can't leave this empty";
    }
    if (value != _password.text) {
      return "Password not matching";
    }
    return null;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _reTypePassword.dispose();
    super.dispose();
  }
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  if (!RegExp(r'^\S+@\S+\.\S+').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null; // Return null if validation passes.
}

String? validateName(String? value) {
// Regular expression to validate a name
  RegExp nameRegex = RegExp(r"^[A-Za-z\s'-]+$");

  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  if (!nameRegex.hasMatch(value)) {
    return 'Please enter a valid name';
  }
  return null; // Return null if validation passes.
}

String? validateIfEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return "Oops, can't leave this empty";
  }
  return null;
}
