import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/application_model.dart';
import '../models/project_model.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading.dart';
import '../widgets/async_value_view.dart';
import '../widgets/responsive_frame.dart';

class MyApplicationsPage extends ConsumerWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(actorApplicationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: AsyncValueView<List<ApplicationModel>>(
        value: applicationsAsync,
        loadingMessage: 'Loading your applications…',
        onRetry: () => ref.invalidate(actorApplicationsListProvider),
        isEmpty: (apps) => apps.isEmpty,
        empty: (_) => const AppEmptyState(
          icon: Icons.assignment_outlined,
          title: 'No applications yet',
          message: 'When you apply to casting calls, they will appear here.',
        ),
        data: (applications) {
          return ResponsiveFrame(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: applications.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
              itemBuilder: (context, index) {
                return _ApplicationCard(
                  application: applications[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectDocStream = ref
        .watch(firestoreProvider)
        .collection('casting_projects')
        .doc(application.projectId)
        .snapshots();

    return StreamBuilder(
      stream: projectDocStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Text(
                'Could not load project',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: AppLoadingIndicator(strokeWidth: 2),
            ),
          );
        }

        final doc = snapshot.data!;
        if (!doc.exists || doc.data() == null) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
              leading: Icon(Icons.link_off_rounded, color: theme.colorScheme.outline),
              title: const Text('Project unavailable'),
              subtitle: const Text('This listing may have been removed.'),
            ),
          );
        }

        final project = ProjectModel.fromMap(doc.data()!, doc.id);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
            title: Text(
              project.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  '${project.city} · Applied ${_formatDate(application.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                _StatusChip(status: application.status),
              ],
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            onTap: () => context.push('/project-detail/${project.id}', extra: project),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final ApplicationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case ApplicationStatus.pending:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        label = 'Pending';
        break;
      case ApplicationStatus.accepted:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        label = 'Accepted';
        break;
      case ApplicationStatus.rejected:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        label = 'Declined';
        break;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
        backgroundColor: bg,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
