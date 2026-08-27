import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobileMax = 599;
  static const double tabletMax = 1024;
}

extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;

  bool get isMobile => _width <= Breakpoints.mobileMax;

  bool get isTablet =>
      _width > Breakpoints.mobileMax && _width <= Breakpoints.tabletMax;

  bool get isDesktop => _width > Breakpoints.tabletMax;
}
