import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Izbor svetle ili tamne teme; podrazumevano prati sistem.
final class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit([super.initialState = ThemeMode.system]);

  void toggle(Brightness current) => emit(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
