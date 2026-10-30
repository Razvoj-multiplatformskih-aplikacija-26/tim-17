import 'package:blocs/blocs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui/ui.dart';

import 'app.dart';
import 'dependencies.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(serbianLatin);
  if (kDebugMode) Bloc.observer = ConsoleBlocObserver(debugPrint);
  runApp(BackofficeApp(dependencies: BackofficeDependencies.fake()));
}
