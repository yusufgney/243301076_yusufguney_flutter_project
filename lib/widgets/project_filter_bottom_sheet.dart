import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_filter.dart';
import '../providers/project_filter_provider.dart';
import '../theme/app_theme.dart';
import 'project_filter_form.dart';

Future<void> showProjectFilterBottomSheet(BuildContext context, WidgetRef ref) {
  final current = ref.read(projectFilterProvider);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final maxH = MediaQuery.sizeOf(sheetContext).height * 0.88;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProjectFilterBottomSheetHeader(),
              Flexible(
                child: ProjectFilterForm(
                  initial: current,
                  onApply: (ProjectFilter filter) {
                    ref.read(projectFilterProvider.notifier).setFilter(filter);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ProjectFilterBottomSheetHeader extends StatelessWidget {
  const ProjectFilterBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingSm,
        AppTheme.spacingLg,
        AppTheme.spacingXs,
      ),
      child: Text(
        'Filter projects',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
