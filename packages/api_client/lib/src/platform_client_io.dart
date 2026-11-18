import 'package:http/http.dart' as http;

const platformKeepsSessionInCookie = false;

http.Client platformHttpClient() => http.Client();
