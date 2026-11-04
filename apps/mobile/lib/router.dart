import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/application_detail_screen.dart';
import 'screens/apply_screen.dart';
import 'screens/home_shell.dart';
import 'screens/job_detail_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/my_applications_screen.dart';

GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
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
