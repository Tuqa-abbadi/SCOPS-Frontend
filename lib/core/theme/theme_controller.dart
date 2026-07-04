import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.dark})
    : _themeMode = initialMode {
    _currentMode = initialMode;
  }

  static const _preferenceKey = 'scops_theme_mode';
  static const _lightValue = 'light';
  static const _darkValue = 'dark';

  ThemeMode _themeMode;
  static ThemeMode _currentMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  static ThemeMode get currentMode => _currentMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  static Future<ThemeController> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString(_preferenceKey);
    return ThemeController(
      initialMode: savedTheme == _lightValue ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setDarkMode(bool isDark) async {
    final nextMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == nextMode) return;

    _themeMode = nextMode;
    _currentMode = nextMode;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _preferenceKey,
      isDark ? _darkValue : _lightValue,
    );
  }
}

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(
      scope != null,
      'ThemeControllerScope was not found in the widget tree.',
    );
    return scope!.notifier!;
  }
}
