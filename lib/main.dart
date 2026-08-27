import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // shared_preferences on web is backed by window.localStorage, which throws
  // when a browser blocks site data (e.g. "Block all cookies", some
  // corporate policies or embedded webviews). Persistence is a nice-to-have;
  // it must never prevent the app from booting.
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (_) {
    preferences = null;
  }

  runApp(PortfolioApp(themeController: ThemeController(preferences)));
}
