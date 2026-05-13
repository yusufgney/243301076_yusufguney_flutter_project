import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Centered loading indicator with optional message; uses theme colors.
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                color: scheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
