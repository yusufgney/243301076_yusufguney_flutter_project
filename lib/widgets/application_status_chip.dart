import 'package:flutter/material.dart';

import '../models/application_model.dart';

class ApplicationStatusChip extends StatelessWidget {
  final ApplicationStatus status;
  final bool showIcon;

  const ApplicationStatusChip({
    super.key,
    required this.status,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg, String label, IconData icon) = switch (status) {
      ApplicationStatus.pending => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        'Pending',
        Icons.hourglass_top_rounded,
      ),
      ApplicationStatus.accepted => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        'Accepted',
        Icons.check_circle_outline,
      ),
      ApplicationStatus.rejected => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        'Declined',
        Icons.cancel_outlined,
      ),
    };

    return Chip(
      avatar: showIcon ? Icon(icon, size: 18, color: fg) : null,
      label: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      backgroundColor: bg,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
