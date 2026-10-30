import 'package:go_router/go_router.dart';

import 'screens/applications_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/applications',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/applications'),
      GoRoute(
        path: '/applications',
        builder: (context, state) => const ApplicationsScreen(),
      ),
    ],
  );
}
