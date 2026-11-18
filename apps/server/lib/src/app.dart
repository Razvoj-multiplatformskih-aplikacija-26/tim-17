import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

import 'cors.dart';
import 'handlers.dart';
import 'http.dart';
import 'sessions.dart';

Handler buildHandler(JobBoardHandlers handlers, SessionHandlers sessions, {required List<String> corsOrigins}) {
  final signedIn = sessions.signedIn;
  final router = RelicRouter()
    ..get(ApiPaths.health, (request) => Response.ok(body: Body.fromString('ok')))
    ..post(ApiPaths.sessions, sessions.logIn)
    ..get(ApiPaths.currentSession, signedIn(sessions.current))
    ..delete(ApiPaths.currentSession, signedIn(sessions.logOut))
    ..get(ApiPaths.jobs, signedIn(handlers.jobs))
    ..get(ApiPaths.job(':id'), signedIn(handlers.job))
    ..get(ApiPaths.myApplications, signedIn(handlers.myApplications))
    ..get(ApiPaths.applications, signedIn(handlers.allApplications))
    ..post(ApiPaths.applications, signedIn(handlers.apply))
    ..post(ApiPaths.statusChanges, signedIn(handlers.changeStatus))
    ..get(ApiPaths.application(':id'), signedIn(handlers.application))
    ..post(ApiPaths.withdrawal(':id'), signedIn(handlers.withdraw))
    ..fallback = respondWith((request) => problemResponse(notFoundRoute));
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(allowOrigins(corsOrigins))
      .addMiddleware(handleErrors())
      .addHandler(router.asHandler);
}

const notFoundRoute = ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'No such route');
