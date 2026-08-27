import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/breakpoints.dart';
import '../theme/theme_controller.dart';
import '../theme/theme_scope.dart';

class NavDestinationData {
  const NavDestinationData({required this.label, required this.path});

  final String label;
  final String path;
}

const List<NavDestinationData> navDestinations = [
  NavDestinationData(label: 'Home', path: '/'),
  NavDestinationData(label: 'Sobre', path: '/sobre'),
  NavDestinationData(label: 'Experiência', path: '/experiencia'),
  NavDestinationData(label: 'Formação', path: '/formacao'),
  NavDestinationData(label: 'Skills', path: '/skills'),
  NavDestinationData(label: 'Projetos', path: '/projetos'),
  NavDestinationData(label: 'Currículo', path: '/curriculo'),
  NavDestinationData(label: 'Contato', path: '/contato'),
];

class AppShell extends StatelessWidget {
  const AppShell({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeToggle = _ThemeToggleButton(
      themeController: ThemeScope.of(context),
    );

    if (context.isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Victor Welter'),
          actions: [themeToggle],
        ),
        drawer: _AppDrawer(currentPath: currentPath),
        body: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Victor Welter'),
        actions: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final destination in navDestinations)
                    TextButton(
                      onPressed: () => context.go(destination.path),
                      child: Text(
                        destination.label,
                        style: TextStyle(
                          fontWeight: currentPath == destination.path
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          themeToggle,
        ],
      ),
      body: child,
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        // `mode` alone is ambiguous when it's `system`: resolve the mode the
        // visitor is actually seeing (accounting for the platform's current
        // brightness) so the icon and the tap target always agree with what
        // is on screen, including on the very first tap.
        final isDark =
            themeController.mode == ThemeMode.dark ||
            (themeController.mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: 'Alternar tema',
          onPressed: () => themeController.setMode(
            isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        );
      },
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          for (final destination in navDestinations)
            ListTile(
              title: Text(destination.label),
              selected: currentPath == destination.path,
              onTap: () {
                Navigator.of(context).pop();
                context.go(destination.path);
              },
            ),
        ],
      ),
    );
  }
}
