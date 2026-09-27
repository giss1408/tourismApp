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

  /// Destination cards per row: one on phones, so each photo is shown
  /// large; more on wider screens.
  static int destinationGridCount(BuildContext context) =>
      destinationColumnsForWidth(MediaQuery.of(context).size.width);

  static int destinationColumnsForWidth(double width) {
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }

  /// Width / height of a destination card: landscape when alone on its row.
  static double destinationCardAspectRatio(int columns) =>
      columns == 1 ? 1.35 : 1.05;

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
