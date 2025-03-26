import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  static const String _themeKey = 'isDarkMode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  Future<void> toggleTheme() async {
    final newState = ThemeState(isDarkMode: !state.isDarkMode);
    emit(newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newState.isDarkMode);
  }
}

class ThemeState {
  final bool isDarkMode;

  ThemeState({required this.isDarkMode});
}
