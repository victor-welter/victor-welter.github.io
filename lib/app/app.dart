import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/theme/theme_scope.dart';
import 'router.dart';

class PortfolioApp extends StatelessWidget {
  PortfolioApp({required this.themeController, super.key})
      : router = buildAppRouter();

  final ThemeController themeController;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Victor Welter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          routerConfig: router,
          builder: (context, child) => ThemeScope(
            controller: themeController,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
