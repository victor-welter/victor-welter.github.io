/// Builds a `mailto:` [Uri] for the Contato page's message form. A pure
/// function — no `url_launcher` call here — so it's unit-testable without
/// any platform-channel mock. See
/// docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md.
Uri buildMailtoUri({
  required String name,
  required String subject,
  required String message,
}) {
  final body = name.isEmpty
      ? message
      : (message.isEmpty ? 'De: $name' : 'De: $name\n\n$message');

  final query = {
    if (subject.isNotEmpty) 'subject': subject,
    if (body.isNotEmpty) 'body': body,
  };

  return Uri(
    scheme: 'mailto',
    path: 'victorwelter2003@gmail.com',
    // Passing an empty (but non-null) string here would still make Uri
    // render a trailing "?" — pass null instead so the empty-query case
    // round-trips to a clean `mailto:victorwelter2003@gmail.com`.
    query: query.isEmpty ? null : _encodeQuery(query),
  );
}

/// Percent-encodes a query map for a `mailto:` URI.
///
/// Deliberately *not* `Uri(queryParameters:)`: that constructor always
/// applies HTML form encoding, which renders a space as `+`. That is correct
/// for an `application/x-www-form-urlencoded` HTTP query string but wrong for
/// a `mailto:` URI (RFC 6068), where `+` has no special meaning — several
/// mail clients show it literally, so a recipient would read
/// "De:+Ana+Souza" instead of "De: Ana Souza". `Uri.encodeComponent`
/// percent-encodes a space as `%20`, which every client decodes correctly.
String _encodeQuery(Map<String, String> params) => params.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    .join('&');
