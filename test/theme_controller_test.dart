import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scops_frontend/core/theme/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to the existing dark theme', () async {
    final controller = await ThemeController.load();

    expect(controller.themeMode, ThemeMode.dark);
  });

  test('persists and restores the light theme', () async {
    final controller = await ThemeController.load();

    await controller.setDarkMode(false);
    final restoredController = await ThemeController.load();

    expect(controller.themeMode, ThemeMode.light);
    expect(restoredController.themeMode, ThemeMode.light);
  });
}
