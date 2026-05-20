import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/application_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading.dart';
import '../widgets/async_value_view.dart';
import '../widgets/confirm_delete_casting_project_dialog.dart';
import '../widgets/responsive_frame.dart';

class ProjectDetailPage extends ConsumerWidget {
  final String projectId;
  final ProjectModel? initialProject;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialProject != null) {
      return _ProjectDetailScaffold(project: initialProject!);
    }

    final projectDoc = ref
        .watch(firestoreProvider)
        .collection('casting_projects')
        .doc(projectId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: projectDoc,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project detail')),
            body: AppErrorState(error: snapshot.error ?? 'Unknown error'),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project detail')),
            body: const AppLoadingIndicator(message: 'Loading project…'),
          );
        }
        final doc = snapshot.data!;
        if (!doc.exists || doc.data() == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project detail')),
            body: const AppEmptyState(
              icon: Icons.link_off_rounded,
              title: 'Project not found',
              message: 'This listing may have been removed or the link is invalid.',
            ),
          );
        }

        final project = ProjectModel.fromMap(doc.data()!, doc.id);
        return _ProjectDetailScaffold(project: project);
      },
    );
  }
}

class _ProjectDetailScaffold extends ConsumerWidget {
  final ProjectModel project;

  const _ProjectDetailScaffold({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userModel = ref.watch(userModelProvider).value;
    final isActor = userModel?.role == UserRole.actor;
    final isAgency = userModel?.role == UserRole.agency;
    final uid = ref.watch(authStateProvider).value?.uid;
    final ownsProject = uid != null && project.createdBy == uid;
    final applicationAsync = ref.watch(actorApplicationForProjectProvider(project.id));
    final applyState = ref.watch(applyToProjectControllerProvider);

    ref.listen(applyToProjectControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
        return;
      }
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasValue && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted.')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Project detail')),
      body: ResponsiveFrame(
        maxContentWidth: 840,
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(project.title, style: theme.textTheme.headlineMedium),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  _DetailRow(label: 'City', value: project.city),
                  _DetailRow(label: 'Gender Requirement', value: project.genderRequirement),
                  _DetailRow(label: 'Age Range', value: '${project.ageMin} - ${project.ageMax}'),
                  _DetailRow(
                    label: 'Skills Required',
                    value: project.skillsRequired.isEmpty
                        ? 'Not specified'
                        : project.skillsRequired.join(', '),
                  ),
                  if (isAgency && ownsProject) ...[
                    const Divider(height: AppTheme.spacingXl),
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            label: 'Manage applicants for this project',
                            child: FilledButton.tonalIcon(
                              onPressed: () => context.push('/project-applicants/${project.id}'),
                              icon: const Icon(Icons.people_outline),
                              label: const Text('View applicants'),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Semantics(
                            label: 'Edit this casting project',
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/edit-project/${project.id}', extra: project),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit project'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Semantics(
                      label: 'Remove this casting listing permanently',
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await confirmDeleteCastingProject(context, project.title);
                          if (!ok || !context.mounted) return;
                          final uid = ref.read(authStateProvider).value?.uid;
                          if (uid == null) return;
                          try {
                            await ref.read(projectServiceProvider).deleteCastingProjectIfOwner(
                                  projectId: project.id,
                                  ownerUid: uid,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed "${project.title}".')),
                              );
                              context.go('/agency-dashboard');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not remove project: $e')),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        label: Text(
                          'Remove listing',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                  if (isActor) ...[
                    const Divider(height: AppTheme.spacingXl),
                    AsyncValueView<ApplicationModel?>(
                      value: applicationAsync,
                      loadingMessage: 'Checking application status…',
                      onRetry: () => ref.invalidate(actorApplicationForProjectProvider(project.id)),
                      data: (app) => _ActorApplicationSection(
                        existing: app,
                        isSubmitting: applyState.isLoading,
                        onApply: () {
                          ref.read(applyToProjectControllerProvider.notifier).apply(project.id);
                        },
                      ),
                    ),
                  ],
                  const Divider(height: AppTheme.spacingXl),
                  Text('Description', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(project.description, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActorApplicationSection extends StatelessWidget {
  final ApplicationModel? existing;
  final bool isSubmitting;
  final VoidCallback onApply;

  const _ActorApplicationSection({
    required this.existing,
    required this.isSubmitting,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (existing != null) {
      final statusLabel = existing!.status.name;
      return Semantics(
        label: 'Application status $statusLabel',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
          title: const Text('You have applied'),
          subtitle: Text('Status: ${existing!.status.name}'),
        ),
      );
    }

    return Semantics(
      label: 'Apply to this project',
      child: FilledButton(
        onPressed: isSubmitting ? null : onApply,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSubmitting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.send_outlined),
            const SizedBox(width: AppTheme.spacingSm),
            Text(isSubmitting ? 'Submitting…' : 'Apply to project'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
