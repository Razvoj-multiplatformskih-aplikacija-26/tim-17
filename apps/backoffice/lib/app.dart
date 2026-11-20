import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'dependencies.dart';
import 'router.dart';
import 'theme_mode.dart';

class BackofficeApp extends StatefulWidget {
  const BackofficeApp({super.key, required this.dependencies, this.themeMode = ThemeMode.system});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final BackofficeDependencies dependencies;
  final ThemeMode themeMode;

  @override
  State<BackofficeApp> createState() => _BackofficeAppState();
}

class _BackofficeAppState extends State<BackofficeApp> {
  late final SessionBloc _session = SessionBloc(
    restoreSession: widget.dependencies.restoreSession,
    logOut: widget.dependencies.logOut,
    admits: AccessPolicy.canReview,
    expirations: widget.dependencies.sessionExpirations,
  )..add(const SessionRestoreRequested());

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeModeCubit(widget.themeMode)),
          BlocProvider.value(value: _session),
        ],
        child: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, session) => switch (session) {
            SessionUnknown() => const _Material(
              key: ValueKey('session-unknown'),
              home: Scaffold(body: LoadingView()),
            ),
            SignedOut(:final reason) => _Material(
              key: ValueKey('signed-out ${reason?.name}'),
              home: LoginScreen(
                title: 'Backoffice za osoblje zadruge',
                logIn: dependencies.logIn,
                reason: reason,
                roleNotAllowedMessage: 'Backoffice je za osoblje zadruge.',
                onSignedIn: (user) => _session.add(SessionStarted(user)),
              ),
            ),
            SignedIn(:final user) => _SignedInApp(key: ValueKey(user.id), staff: user, dependencies: dependencies),
          },
        ),
      ),
    );
  }
}

class _SignedInApp extends StatefulWidget {
  const _SignedInApp({super.key, required this.staff, required this.dependencies});

  final User staff;
  final BackofficeDependencies dependencies;

  @override
  State<_SignedInApp> createState() => _SignedInAppState();
}

class _SignedInAppState extends State<_SignedInApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: widget.staff,
      child: BlocProvider(
        create: (_) => ApplicationsBoardBloc(
          getAllApplications: dependencies.getAllApplications,
          changeApplicationStatus: dependencies.changeApplicationStatus,
          staff: widget.staff,
        )..add(const BoardRequested()),
        child: _Material(router: _router),
      ),
    );
  }
}

class _Material extends StatelessWidget {
  const _Material({super.key, this.home, this.router});

  static const _delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  final Widget? home;
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeCubit>().state;
    final router = this.router;
    if (router != null) {
      return MaterialApp.router(
        title: 'Jobly Backoffice',
        debugShowCheckedModeBanner: false,
        theme: JoblyTheme.light(),
        darkTheme: JoblyTheme.dark(),
        themeMode: themeMode,
        locale: BackofficeApp.locale,
        supportedLocales: const [BackofficeApp.locale],
        localizationsDelegates: _delegates,
        routerConfig: router,
      );
    }
    return MaterialApp(
      title: 'Jobly Backoffice',
      debugShowCheckedModeBanner: false,
      theme: JoblyTheme.light(),
      darkTheme: JoblyTheme.dark(),
      themeMode: themeMode,
      locale: BackofficeApp.locale,
      supportedLocales: const [BackofficeApp.locale],
      localizationsDelegates: _delegates,
      onGenerateInitialRoutes: (_) => [MaterialPageRoute<void>(builder: (_) => home!)],
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => home!),
    );
  }
}
