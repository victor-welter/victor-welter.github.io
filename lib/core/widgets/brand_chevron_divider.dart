import 'package:flutter/material.dart';

import 'brand_chevron_mark.dart';

/// A section-break divider reusing [BrandChevronMark] in place of a
/// generic [Divider] — see
/// docs/superpowers/specs/2026-09-01-portfolio-redesign-design.md.
class BrandChevronDivider extends StatelessWidget {
  const BrandChevronDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(width: 32, height: 16, child: BrandChevronMark()),
      ),
    );
  }
}
