import 'app_theme.dart';

abstract final class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 600;

  static const double medium = 900;

  static const double authCardMaxWidth = 440;

  static const double contentMaxWidth = 880;

  static const double projectGrid = 900;

  static double horizontalMargin(double screenWidth) {
    if (screenWidth >= medium) return AppTheme.spacingXl;
    if (screenWidth >= compact) return AppTheme.spacingLg;
    return AppTheme.spacingMd;
  }
}
