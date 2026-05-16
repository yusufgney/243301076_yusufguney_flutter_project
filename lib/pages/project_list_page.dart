import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/project_filter_provider.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_filter_bottom_sheet.dart';
import '../widgets/responsive_frame.dart';

class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);
    final filter = ref.watch(projectFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Casting Projects'),
        actions: [
          if (filter.hasAnyActive)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppTheme.spacingXs),
                child: Semantics(
                  label: 'Filters active',
                  child: Icon(
                    Icons.filter_alt,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Quick filters',
            icon: const Icon(Icons.filter_list),
            onPressed: () => showProjectFilterBottomSheet(context, ref),
          ),
          IconButton(
            tooltip: 'Filter page',
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/project-filters'),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'Loading projects…'),
        error: (error, stack) => AppErrorState(error: error.toString()),
        data: (projects) {
          if (projects.isEmpty) {
            return AppEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No casting projects',
              message: filter.hasAnyActive
                  ? 'Nothing matches your current filters. Try widening your search.'
                  : 'There are no open listings right now. Check back soon.',
              actionLabel: filter.hasAnyActive ? 'Adjust filters' : null,
              onAction: filter.hasAnyActive ? () => showProjectFilterBottomSheet(context, ref) : null,
            );
          }

          return ResponsiveFrame(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isGrid = constraints.maxWidth >= AppBreakpoints.projectGrid;

                if (!isGrid) {
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: projects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingMd),
                    itemBuilder: (context, index) => ProjectCard(
                      project: projects[index],
                      onTap: () => context.push(
                        '/project-detail/${projects[index].id}',
                        extra: projects[index],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.spacingMd,
                    mainAxisSpacing: AppTheme.spacingMd,
                    childAspectRatio: 1.45,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) => ProjectCard(
                    project: projects[index],
                    onTap: () => context.push(
                      '/project-detail/${projects[index].id}',
                      extra: projects[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
