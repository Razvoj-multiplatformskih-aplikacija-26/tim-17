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

class JoblyApp extends StatefulWidget {
  const JoblyApp({super.key, required this.dependencies, this.themeMode = ThemeMode.system});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final AppDependencies dependencies;
  final ThemeMode themeMode;

  @override
  State<JoblyApp> createState() => _JoblyAppState();
}

class _JoblyAppState extends State<JoblyApp> {
  late final SessionBloc _session = SessionBloc(
    restoreSession: widget.dependencies.restoreSession,
    logOut: widget.dependencies.logOut,
    admits: AccessPolicy.canApply,
    expirations: widget.dependencies.sessionExpirations,
  )..add(const SessionRestoreRequested());
  late final JobsBloc _jobs = JobsBloc(
    getJobs: widget.dependencies.getJobs,
    applyForJob: widget.dependencies.applyForJob,
  );
  late final MyApplicationsBloc _applications = MyApplicationsBloc(
    getMyApplications: widget.dependencies.getMyApplications,
    withdrawApplication: widget.dependencies.withdrawApplication,
  );
  late final GoRouter _router = createRouter(_session);

  @override
  void dispose() {
    _router.dispose();
    _applications.close();
    _jobs.close();
    _session.close();
    super.dispose();
  }

  void _onSessionChanged(BuildContext context, SessionState session) {
    final student = switch (session) {
      SignedIn(:final user) => user,
      _ => null,
    };
    _jobs.add(JobsStudentChanged(student));
    _applications.add(MyApplicationsStudentChanged(student));
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeModeCubit(widget.themeMode)),
          BlocProvider.value(value: _session),
          BlocProvider.value(value: _jobs),
          BlocProvider.value(value: _applications),
        ],
        child: BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) => current is! SessionUnknown,
          listener: _onSessionChanged,
          child: BlocBuilder<ThemeModeCubit, ThemeMode>(
            builder: (context, themeMode) => MaterialApp.router(
              title: 'Jobly',
              debugShowCheckedModeBanner: false,
              theme: JoblyTheme.light(),
              darkTheme: JoblyTheme.dark(),
              themeMode: themeMode,
              locale: JoblyApp.locale,
              supportedLocales: const [JoblyApp.locale],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}
