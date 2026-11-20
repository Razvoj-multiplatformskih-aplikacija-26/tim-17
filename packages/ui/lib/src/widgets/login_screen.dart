import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:use_cases/use_cases.dart' show LogIn;

import '../text/failures.dart';
import 'gradient_button.dart';
import 'jobly_wordmark.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.title,
    required this.logIn,
    required this.onSignedIn,
    required this.roleNotAllowedMessage,
    this.reason,
    this.appBar,
  });

  final String title;
  final LogIn logIn;
  final void Function(User user) onSignedIn;
  final String roleNotAllowedMessage;
  final SignOutReason? reason;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormBloc(logIn: logIn),
      child: BlocListener<LoginFormBloc, LoginFormState>(
        listener: (context, state) {
          if (state case LoginSucceeded(:final user)) onSignedIn(user);
        },
        child: Scaffold(
          appBar: appBar,
          body: SafeArea(
            child: _LoginForm(title: title, reason: reason, roleNotAllowedMessage: roleNotAllowedMessage),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.title, required this.roleNotAllowedMessage, this.reason});

  final String title;
  final String roleNotAllowedMessage;
  final SignOutReason? reason;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<LoginFormBloc>().add(LoginSubmitted(username: _username.text, password: _password.text));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<LoginFormBloc>().state;
    final busy = state is LoginSubmitting;
    final message = switch (state) {
      LoginRejected() => 'Pogrešno korisničko ime ili lozinka.',
      LoginFailed(:final cause) => failureMessage(cause),
      _ => switch (widget.reason) {
        SignOutReason.roleNotAllowed => widget.roleNotAllowedMessage,
        SignOutReason.expired => sessionExpiredMessage,
        SignOutReason.unreachable => serverUnreachableMessage,
        SignOutReason.loggedOut || null => null,
      },
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: JoblyWordmark(size: 44)),
                const SizedBox(height: 12),
                Semantics(
                  header: true,
                  child: Text(widget.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 28),
                if (message != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _username,
                  enabled: !busy,
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Korisničko ime'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  enabled: !busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(labelText: 'Lozinka'),
                ),
                const SizedBox(height: 28),
                Center(
                  child: busy
                      ? const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator(semanticsLabel: 'Prijava u toku')),
                        )
                      : GradientButton(onPressed: _submit, icon: Icons.login_rounded, label: 'Prijavi se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
