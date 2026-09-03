import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
