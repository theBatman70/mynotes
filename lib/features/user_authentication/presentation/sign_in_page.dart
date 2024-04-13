import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/routes/routes.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white10,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          height: double.infinity,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                    vertical: MediaQuery.sizeOf(context).height * 0.15),
                child: Column(
                  children: [
                    // Header section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your ideas,',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                        const Image(
                          image: AssetImage(
                              'assets/images/my_notes_logo-black-outlined-no_bg.png'), // Replace with your logo image
                          height: 70.0,
                          width: 80.0,
                        ),
                        Text(
                          'your plans',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Your notes.',
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),

              // Sign in Options
              Center(
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                      bottom: MediaQuery.sizeOf(context).height * 0.1),
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Sign in to continue',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),

                      // Google Sign In
                      Transform.scale(
                        scale: 0.85,
                        child: IconButton(
                            onPressed: () async {
                              context.read<AuthBloc>().add(const LoginWithGoogle());
                            },
                            icon: const Image(
                                image: AssetImage(
                                    'assets/images/google-sign-in-button.png'))),
                      ),
                      const SizedBox(height: 20.0),

                      // Email & Password
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(emailRegisterRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ), // Add your button action here
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Email & Password',
                              style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.mail,
                              color: Colors.black54,
                            )
                          ],
                        ),
                      ),

                      // OR separator
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            color: Colors.grey[300],
                            width: 100.0,
                            height: 1.0,
                          ),
                          const SizedBox(width: 10.0),
                          const Text('OR'),
                          const SizedBox(width: 10.0),
                          Container(
                            color: Colors.grey[300],
                            width: 100.0,
                            height: 1.0,
                          ),
                        ],
                      ),

                      // Anonymous Option
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          context.read<AuthBloc>().add(const LoginAnonymously());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                        ), // Add your button action here
                        child: Text(
                          'Anonymous Login',
                          style: GoogleFonts.ooohBaby(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
