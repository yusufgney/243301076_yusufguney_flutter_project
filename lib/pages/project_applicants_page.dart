import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/application_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../providers/actor_provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/access_denied_body.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading.dart';
import '../widgets/application_status_chip.dart';
import '../widgets/async_value_view.dart';
import '../widgets/responsive_frame.dart';

class ProjectApplicantsPage extends ConsumerWidget {
  final String projectId;

  const ProjectApplicantsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userModelProvider).value?.role;
    if (role != UserRole.agency) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applicants')),
        body: const AccessDeniedBody(
          title: 'Applicants',
          message: 'Only agency accounts can review applicants for their projects.',
        ),
      );
    }

    final projectDoc = ref.watch(firestoreProvider).collection('casting_projects').doc(projectId).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: projectDoc,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Applicants')),
            body: AppErrorState(error: snapshot.error ?? 'Unknown error'),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Applicants')),
            body: const AppLoadingIndicator(message: 'Loading project…'),
          );
        }
        final doc = snapshot.data!;
        if (!doc.exists || doc.data() == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Applicants')),
            body: const AppEmptyState(
              icon: Icons.link_off_rounded,
              title: 'Project not found',
              message: 'This listing may have been removed.',
            ),
          );
        }

        final project = ProjectModel.fromMap(doc.data()!, doc.id);
        final uid = ref.watch(authStateProvider).value?.uid;
        if (uid == null || project.createdBy != uid) {
          return Scaffold(
            appBar: AppBar(title: const Text('Applicants')),
            body: const AccessDeniedBody(
              title: 'Access restricted',
              message: 'You can only manage applicants for your own projects.',
            ),
          );
        }

        return _ApplicantsScaffold(project: project);
      },
    );
  }
}

class _ApplicantsScaffold extends ConsumerWidget {
  final ProjectModel project;

  const _ApplicantsScaffold({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final applicationsAsync = ref.watch(applicationsForProjectProvider(project.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/agency-dashboard'),
        ),
      ),
      body: AsyncValueView<List<ApplicationModel>>(
        value: applicationsAsync,
        loadingMessage: 'Loading applications…',
        onRetry: () => ref.invalidate(applicationsForProjectProvider(project.id)),
        isEmpty: (applications) => applications.isEmpty,
        empty: (_) => AppEmptyState(
          icon: Icons.people_outline,
          title: 'No applications yet',
          message: 'When actors apply to "${project.title}", they will appear here.',
        ),
        data: (applications) {
          return ResponsiveFrame(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: applications.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          '${applications.length} applicant${applications.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }
                final app = applications[index - 1];
                return _ApplicantCard(
                  application: app,
                  projectId: project.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends ConsumerStatefulWidget {
  final ApplicationModel application;
  final String projectId;

  const _ApplicantCard({
    required this.application,
    required this.projectId,
  });

  @override
  ConsumerState<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends ConsumerState<_ApplicantCard> {
  bool _busy = false;

  Future<void> _setStatus(ApplicationStatus status) async {
    setState(() => _busy = true);
    try {
      await ref.read(applicationServiceProvider).updateApplicationStatus(
            actorId: widget.application.actorId,
            projectId: widget.projectId,
            status: status,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application marked as ${status.name}.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final actorAsync = ref.watch(actorByIdProvider(widget.application.actorId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primaryContainer,
                  child: actorAsync.when(
                    data: (actor) => Text(
                      (actor?.fullName.isNotEmpty == true ? actor!.fullName[0] : '?').toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    loading: () => const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stackTrace) => Icon(Icons.person, color: scheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      actorAsync.when(
                        data: (actor) => Text(
                          actor?.fullName.isNotEmpty == true ? actor!.fullName : 'Actor ${widget.application.actorId}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        loading: () => const Text('Loading…'),
                        error: (error, stackTrace) => Text(
                          'Actor ${widget.application.actorId}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        'Applied ${_formatDate(widget.application.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      ApplicationStatusChip(status: widget.application.status, showIcon: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            OutlinedButton.icon(
              onPressed: () => context.push('/agency-actor/${widget.application.actorId}'),
              icon: const Icon(Icons.person_search_outlined, size: 20),
              label: const Text('View full profile'),
            ),
            if (widget.application.status == ApplicationStatus.pending) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _setStatus(ApplicationStatus.accepted),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 20),
                    label: const Text('Accept'),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _setStatus(ApplicationStatus.rejected),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

