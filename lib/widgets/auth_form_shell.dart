import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_theme.dart';

class AuthFormShell extends StatelessWidget {
  final Widget child;

  const AuthFormShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final margin = AppBreakpoints.horizontalMargin(constraints.maxWidth);
          final maxCard = min(
            AppBreakpoints.authCardMaxWidth,
            constraints.maxWidth - 2 * margin,
          );

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(margin),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCard > 0 ? maxCard : constraints.maxWidth),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
