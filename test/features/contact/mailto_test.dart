import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/contact/mailto.dart';

void main() {
  test('builds a mailto uri with a "De:" prefix and encoded fields', () {
    final uri = buildMailtoUri(
      name: 'Ana Souza',
      subject: 'Proposta de projeto',
      message: 'Olá, gostaria de conversar sobre uma vaga.',
    );

    expect(uri.scheme, 'mailto');
    expect(uri.path, 'victorwelter2003@gmail.com');
    expect(uri.queryParameters['subject'], 'Proposta de projeto');
    expect(
      uri.queryParameters['body'],
      'De: Ana Souza\n\nOlá, gostaria de conversar sobre uma vaga.',
    );
  });

  test('omits the "De:" prefix when name is empty', () {
    final uri = buildMailtoUri(
      name: '',
      subject: 'Oi',
      message: 'Mensagem sem nome.',
    );

    expect(uri.queryParameters['body'], 'Mensagem sem nome.');
  });

  test('omits subject/body query params entirely when both are empty', () {
    final uri = buildMailtoUri(name: '', subject: '', message: '');

    expect(uri.queryParameters.containsKey('subject'), isFalse);
    expect(uri.queryParameters.containsKey('body'), isFalse);
    expect(uri.toString(), 'mailto:victorwelter2003@gmail.com');
  });

  test('percent-encodes special characters in the subject', () {
    final uri = buildMailtoUri(
      name: '',
      subject: 'Olá & bem-vindo?',
      message: 'Linha 1\nLinha 2',
    );

    expect(uri.toString(), contains('subject=Ol%C3%A1'));
  });

  // Spaces must be percent-encoded as %20, never form-encoded as "+".
  // These assertions run against uri.toString() on purpose: reading back via
  // uri.queryParameters decodes "+" to a space too, so a form-encoded URI
  // would pass every read-back assertion above while real mail clients
  // (Outlook, some webmail) render the "+" literally.
  test('encodes spaces as %20, not "+" (RFC 6068 mailto, not form data)', () {
    final uri = buildMailtoUri(
      name: 'Ana Souza',
      subject: 'Proposta de projeto',
      message: 'Olá, gostaria de conversar sobre uma vaga.',
    );

    final encoded = uri.toString();
    expect(encoded, isNot(contains('+')));
    expect(encoded, contains('subject=Proposta%20de%20projeto'));
    expect(encoded, contains('body=De%3A%20Ana%20Souza'));
    expect(encoded, contains('Ana%20Souza'));
  });
}
