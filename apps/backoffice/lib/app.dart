import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'dependencies.dart';
import 'router.dart';

class BackofficeApp extends StatefulWidget {
  const BackofficeApp({super.key, required this.dependencies});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final BackofficeDependencies dependencies;

  @override
  State<BackofficeApp> createState() => _BackofficeAppState();
}

class _BackofficeAppState extends State<BackofficeApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.dependencies,
      child: MaterialApp.router(
        title: 'Jobly Backoffice',
        theme: JoblyTheme.light(),
        darkTheme: JoblyTheme.dark(),
        themeMode: ThemeMode.system,
        locale: BackofficeApp.locale,
        supportedLocales: const [BackofficeApp.locale],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router,
      ),
    );
  }
}
