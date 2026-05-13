import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_filter.dart';
import '../providers/project_filter_provider.dart';
import '../widgets/project_filter_form.dart';

/// Full-screen project filters page.
class ProjectFilterPage extends ConsumerWidget {
  const ProjectFilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(projectFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Projects'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(projectFilterProvider.notifier).clear();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ProjectFilterForm(
        initial: current,
        onApply: (ProjectFilter filter) {
          ref.read(projectFilterProvider.notifier).setFilter(filter);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
