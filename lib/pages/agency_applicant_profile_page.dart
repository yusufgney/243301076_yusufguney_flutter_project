import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/actor_model.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';
import '../providers/actor_provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/access_denied_body.dart';
import '../widgets/application_status_chip.dart';
import '../widgets/async_value_view.dart';
import '../widgets/responsive_frame.dart';

class AgencyApplicantProfilePage extends ConsumerStatefulWidget {
  final String actorId;
  final String? projectId;

  const AgencyApplicantProfilePage({
    super.key,
    required this.actorId,
    this.projectId,
  });

  @override
  ConsumerState<AgencyApplicantProfilePage> createState() => _AgencyApplicantProfilePageState();
}

class _AgencyApplicantProfilePageState extends ConsumerState<AgencyApplicantProfilePage> {
  bool _busy = false;

  Future<void> _setStatus(ApplicationStatus status) async {
    if (widget.projectId == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(applicationServiceProvider).updateApplicationStatus(
            actorId: widget.actorId,
            projectId: widget.projectId!,
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
    final role = ref.watch(userModelProvider).value?.role;
    if (role != UserRole.agency) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applicant')),
        body: const AccessDeniedBody(
          title: 'Restricted',
          message: 'Only agency accounts can open applicant profiles.',
        ),
      );
    }

    final profileAsync = ref.watch(actorProfileStreamByIdProvider(widget.actorId));
    final applicationAsync = widget.projectId != null
        ? ref.watch(applicationByActorAndProjectProvider((
            actorId: widget.actorId,
            projectId: widget.projectId!,
          )))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicant profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/agency-dashboard'),
        ),
      ),
      body: AsyncValueView<ActorModel?>(
        value: profileAsync,
        loadingMessage: 'Loading profile…',
        onRetry: () => ref.invalidate(actorProfileStreamByIdProvider(widget.actorId)),
        data: (actor) {
          return ResponsiveFrame(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage:
                          (actor?.profileImageUrl != null) ? NetworkImage(actor!.profileImageUrl!) : null,
                      child: (actor?.profileImageUrl == null)
                          ? const Icon(Icons.person, size: 56)
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Text(
                    actor == null
                        ? 'Profile not completed'
                        : (actor.fullName.isEmpty ? 'Unnamed actor' : actor.fullName),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Profile ID: ${widget.actorId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  if (actor == null) ...[
                    Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: Text(
                                'This actor has not completed a public profile yet.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (applicationAsync != null) ...[
                    AsyncValueView<ApplicationModel?>(
                      value: applicationAsync,
                      loadingMessage: 'Loading application status…',
                      onRetry: () => ref.invalidate(applicationByActorAndProjectProvider((
                        actorId: widget.actorId,
                        projectId: widget.projectId ?? '',
                      ))),
                      data: (app) {
                        if (app == null) return const SizedBox.shrink();
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Application Status',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    ApplicationStatusChip(status: app.status, showIcon: true),
                                  ],
                                ),
                                if (app.status == ApplicationStatus.pending) ...[
                                  const SizedBox(height: AppTheme.spacingMd),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: _busy ? null : () => _setStatus(ApplicationStatus.accepted),
                                          icon: _busy
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Icon(Icons.check, size: 20),
                                          label: const Text('Accept'),
                                        ),
                                      ),
                                      const SizedBox(width: AppTheme.spacingSm),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _busy ? null : () => _setStatus(ApplicationStatus.rejected),
                                          icon: const Icon(Icons.close, size: 20),
                                          label: const Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  if (actor != null) ...[
                    _SectionTitle(title: 'Basics'),
                    _InfoRow(label: 'Gender', value: actor.gender.isEmpty ? '—' : actor.gender),
                    _InfoRow(label: 'Ethnicity', value: actor.ethnicity.isEmpty ? '—' : actor.ethnicity),
                    _InfoRow(label: 'Age', value: actor.age > 0 ? '${actor.age}' : '—'),
                    _InfoRow(label: 'Location', value: _formatLocation(actor)),
                    _InfoRow(label: 'Height', value: actor.height > 0 ? '${actor.height} cm' : '—'),
                    _InfoRow(label: 'Weight', value: actor.weight > 0 ? '${actor.weight} kg' : '—'),
                    const SizedBox(height: AppTheme.spacingMd),
                    _SectionTitle(title: 'Skills'),
                    Text(
                      actor.skills.isEmpty ? '—' : actor.skills.join(', '),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    _SectionTitle(title: 'Bio'),
                    Text(
                      actor.bio.isEmpty ? '—' : actor.bio,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatLocation(ActorModel a) {
    if (a.city.isEmpty && a.country.isEmpty) return '—';
    if (a.city.isEmpty) return a.country;
    if (a.country.isEmpty) return a.city;
    return '${a.country}, ${a.city}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
