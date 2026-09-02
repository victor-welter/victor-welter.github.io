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
    // Passing an empty (but non-null) map here would still make Uri render
    // a trailing "?" — pass null instead so the empty-query case round-trips
    // to a clean `mailto:victorwelter2003@gmail.com`.
    queryParameters: query.isEmpty ? null : query,
  );
}
