import 'dart:convert';
import 'dart:isolate';

import 'package:hashlib/hashlib.dart';
import 'package:hashlib/random.dart';
import 'package:pool/pool.dart';

final _hashing = Pool(4);

Future<String> hashPassword(String password) => _hashing.withResource(
  () => Isolate.run(() => argon2id(utf8.encode(password), randomBytes(16), security: Argon2Security.owasp2).encoded()),
);

Future<bool> verifyPassword(String password, String encoded) =>
    _hashing.withResource(() => Isolate.run(() => argon2Verify(encoded, utf8.encode(password))));
