import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/core/theme/theme_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<PortfolioApp> buildApp() async {
    final preferences = await SharedPreferences.getInstance();
    return PortfolioApp(themeController: ThemeController(preferences));
  }

  testWidgets('renders the home page at the initial route', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    expect(
      find.text('PLACEHOLDER: apresentação principal da Home (Fase 5).'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to the projects route', (tester) async {
    final app = await buildApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.router.go('/projetos');
    await tester.pumpAndSettle();

    expect(
      find.text('PLACEHOLDER: cards de projetos (Fase 6).'),
      findsOneWidget,
    );
  });

  testWidgets('shows the not-found page for an unknown route', (tester) async {
    final app = await buildApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.router.go('/rota-que-nao-existe');
    await tester.pumpAndSettle();

    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
