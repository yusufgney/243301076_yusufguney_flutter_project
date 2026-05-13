import 'app_theme.dart';

/// Layout breakpoints and responsive helpers used across the app.
abstract final class AppBreakpoints {
  AppBreakpoints._();

  /// Phone portrait / narrow layouts.
  static const double compact = 600;

  /// Tablet-ish widths.
  static const double medium = 900;

  /// Auth card max width on large screens.
  static const double authCardMaxWidth = 440;

  /// Default max width for reading-heavy pages (detail, legal, etc.).
  static const double contentMaxWidth = 880;

  /// Project grid switches to two columns at this width.
  static const double projectGrid = 900;

  static double horizontalMargin(double screenWidth) {
    if (screenWidth >= medium) return AppTheme.spacingXl;
    if (screenWidth >= compact) return AppTheme.spacingLg;
    return AppTheme.spacingMd;
  }
}
