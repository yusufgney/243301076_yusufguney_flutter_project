import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_theme.dart';

class ResponsiveFrame extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;

  const ResponsiveFrame({
    super.key,
    required this.child,
    this.maxContentWidth = AppBreakpoints.contentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final m = AppBreakpoints.horizontalMargin(constraints.maxWidth);
        final innerMax = min(maxContentWidth, constraints.maxWidth - 2 * m);

        return Padding(
          padding: EdgeInsets.fromLTRB(m, AppTheme.spacingLg, m, AppTheme.spacingLg),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: innerMax > 0 ? innerMax : constraints.maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
