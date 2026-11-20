import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../dependencies.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>();
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) => LoginScreen(
        title: 'Prijava za studente',
        logIn: context.read<AppDependencies>().logIn,
        reason: switch (state) {
          SignedOut(:final reason) => reason,
          _ => null,
        },
        roleNotAllowedMessage: 'Aplikacija je za studente. Osoblje koristi backoffice.',
        onSignedIn: (user) => session.add(SessionStarted(user)),
      ),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: LoadingView());
}
