import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/features/user_authentication/bloc/auth_bloc.dart';
import 'package:mynotes/features/user_authentication/presentation/email_login_pages/email_login_view.dart';
import 'package:mynotes/features/user_authentication/presentation/sign_in_page.dart';
import 'package:mynotes/routes/routes.dart';
import 'package:mynotes/features/note/presentation/notes_view.dart';
import 'package:mynotes/features/note/presentation/create_update_note_view.dart';
import 'package:mynotes/features/user_authentication/presentation/email_login_pages/email_register_view.dart';
import 'package:mynotes/features/user_authentication/presentation/email_login_pages/verify_email.dart';
import 'package:mynotes/features/user_authentication/auth/firebase_auth_service.dart';
import 'package:mynotes/utils/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BlocProvider(
      create: (context) => AuthBloc(FirebaseAuthService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: TAppTheme.theme,
        home: MyApp(),
        routes: {
          emailLoginRoute: (context) => const EmailLoginView(),
          emailRegisterRoute: (context) => const EmailRegisterView(),
          emailVerifyRoute: (context) => const VerifyEmailView(),
          homeRoute: (context) => const NotesView(),
          createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
          signInRoute: (context) => const SignInPage(),
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state is AuthStateLoading) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
                  child: AlertDialog(
                    icon: Center(child: CircularProgressIndicator()),
                  ),
                ));
      } else if (state is AuthStateLoadingDone) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        debugPrint(state.toString());
        debugPrint(state.user.toString());
        return const NotesView();
      } else if (state is EmailNeedsVerification) {
        context.read<AuthBloc>().add(const SendUserEmailVerification());
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const SignInPage();
      } else {
        debugPrint(state.toString());
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}
