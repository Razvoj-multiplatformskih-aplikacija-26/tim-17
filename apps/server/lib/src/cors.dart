import 'package:relic/relic.dart';

const _safeMethods = {Method.get, Method.head, Method.options};

Middleware allowOrigins(List<String> origins) =>
    (Handler next) => (Request request) async {
      final origin = request.headers.origin?.toString();
      final allowed = origin != null && origins.contains(origin);
      if (origin != null && !allowed && !_safeMethods.contains(request.method)) {
        return Response.forbidden(body: Body.fromString('Origin not allowed'), headers: Headers.build(_vary));
      }
      if (request.method == Method.options) {
        return Response.noContent(
          headers: Headers.build((headers) => allowed ? _allow(headers, origin) : _vary(headers)),
        );
      }
      final result = await next(request);
      if (result is! Response) return result;
      return result.copyWith(
        headers: result.headers.transform((headers) => allowed ? _allow(headers, origin) : _vary(headers)),
      );
    };

void _allow(MutableHeaders headers, String origin) {
  headers['Access-Control-Allow-Origin'] = [origin];
  headers['Access-Control-Allow-Methods'] = ['GET, POST, DELETE, OPTIONS'];
  headers['Access-Control-Allow-Headers'] = ['Content-Type, Authorization'];
  headers['Access-Control-Allow-Credentials'] = ['true'];
  _vary(headers);
}

void _vary(MutableHeaders headers) => headers['Vary'] = ['Origin'];
