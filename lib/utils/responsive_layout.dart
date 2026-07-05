import 'package:flutter/widgets.dart';

class ResponsiveLayout {
  static const double tabletBreakpoint = 700;
  static const double desktopBreakpoint = 1100;

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static int destinationGridCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    }
    if (isTablet(context)) {
      return 3;
    }
    return 2;
  }

  static double featuredCardWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 320;
    }
    if (isTablet(context)) {
      return 280;
    }
    return 220;
  }
}
