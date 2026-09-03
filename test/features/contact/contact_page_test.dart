import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/section_card.dart';
import 'package:portfolio/features/contact/contact_page.dart';

void main() {
  testWidgets(
    'shows the message form fields, send button, and contact info',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ContactPage()));

      expect(find.widgetWithText(TextField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Assunto'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Mensagem'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Enviar'), findsOneWidget);

      expect(find.text('victorwelter2003@gmail.com'), findsOneWidget);
      expect(find.text('linkedin.com/in/victor-welter'), findsOneWidget);
      expect(find.text('github.com/victor-welter'), findsOneWidget);
      expect(
        find.text('Três de Maio, Rio Grande do Sul, Brasil'),
        findsOneWidget,
      );
    },
  );

  // "Enviar" opens a mailto: link, and url_launcher_web reports success
  // whether or not the visitor actually has a mail client — so there is no
  // signal to drive a result message off. This standing hint is the only
  // thing telling a visitor what the button does, and the only fallback for
  // one whose machine can't handle mailto:, so it has to stay put.
  testWidgets('explains what "Enviar" does and repeats the address', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ContactPage()));

    final hint = find.textContaining('cliente de e-mail padrão');
    expect(hint, findsOneWidget);
    expect(
      tester.widget<Text>(hint).data,
      contains('victorwelter2003@gmail.com'),
    );
  });

  // flutter_test's default 800x600 surface is *tablet* under Breakpoints
  // (isMobile is width <= 599), so the test above only ever exercises the
  // side-by-side IntrinsicHeight/Row branch. Cover the stacked one too.
  testWidgets('stacks both panels at mobile width', (tester) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ContactPage()));
    await tester.pump();

    expect(tester.takeException(), isNull);

    final cards = find.byType(SectionCard);
    expect(cards, findsNWidgets(2));

    // Stacked, not side by side: the info panel starts below the form.
    final form = tester.getRect(cards.at(0));
    final info = tester.getRect(cards.at(1));
    expect(info.top, greaterThanOrEqualTo(form.bottom));
  });
}
