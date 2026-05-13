import 'package:flutter/material.dart';

import 'app_empty_state.dart';

/// Role or permission mismatch (full-page body).
class AccessDeniedBody extends StatelessWidget {
  final String title;
  final String message;

  const AccessDeniedBody({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.lock_outline_rounded,
      title: title,
      message: message,
    );
  }
}
