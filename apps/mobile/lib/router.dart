import 'dart:async';

import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/application_detail_screen.dart';
import 'screens/apply_screen.dart';
import 'screens/home_shell.dart';
import 'screens/job_detail_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/sign_in_screen.dart';

GoRouter createRouter(SessionBloc session) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final refresh = _SessionRefresh(session);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) => _guard(session.state, state.matchedLocation),
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(path: '/login', builder: (context, state) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const JobsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/applications', builder: (context, state) => const MyApplicationsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (context, state) => JobDetailScreen(id: JobPostingId(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'apply',
            builder: (context, state) => ApplyScreen(jobId: JobPostingId(state.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(
        path: '/applications/:id',
        builder: (context, state) => ApplicationDetailScreen(
          id: JobApplicationId(state.pathParameters['id']!),
          justApplied: state.extra == true,
        ),
      ),
    ],
  );
}

String? _guard(SessionState session, String location) => switch (session) {
  SessionUnknown() => location == '/start' ? null : '/start',
  SignedOut() => location == '/login' ? null : '/login',
  SignedIn() => location == '/start' || location == '/login' ? '/' : null,
};

final class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(SessionBloc session) {
    _subscription = session.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<SessionState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
