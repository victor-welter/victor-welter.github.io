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
    final colorScheme = Theme.of(context).colorScheme;

    // TextButton's Material 3 default foreground is always colorScheme.primary,
    // regardless of the TextTheme's own label color — so the active/inactive
    // distinction from the design spec must be set explicitly per button.
    Color navLabelColor(String path) =>
        currentPath == path ? colorScheme.primary : colorScheme.onSurfaceVariant;

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

    if (context.isTablet) {
      final home = navDestinations.first;
      final overflowDestinations = navDestinations.skip(1);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Victor Welter'),
          actions: [
            _NavBarItem(
              label: home.label,
              isActive: currentPath == home.path,
              color: navLabelColor(home.path),
              onTap: () => context.go(home.path),
            ),
            PopupMenuButton<String>(
              tooltip: 'Mais opções de navegação',
              onSelected: (path) => context.go(path),
              itemBuilder: (context) => [
                for (final destination in overflowDestinations)
                  PopupMenuItem<String>(
                    value: destination.path,
                    child: Text(
                      destination.label,
                      style: TextStyle(
                        color: navLabelColor(destination.path),
                        fontWeight: currentPath == destination.path
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Mais'),
                    Icon(Icons.arrow_drop_down),
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
                    _NavBarItem(
                      label: destination.label,
                      isActive: currentPath == destination.path,
                      color: navLabelColor(destination.path),
                      onTap: () => context.go(destination.path),
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

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: color),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        AnimatedContainer(
          key: const Key('nav-active-indicator'),
          duration: const Duration(milliseconds: 150),
          height: 2,
          width: 20,
          margin: const EdgeInsets.only(top: 2),
          color: isActive ? color : Colors.transparent,
        ),
      ],
    );
  }
}
