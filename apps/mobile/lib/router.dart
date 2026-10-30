import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_shell.dart';
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
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const JobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/applications',
                builder: (context, state) => const MyApplicationsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
