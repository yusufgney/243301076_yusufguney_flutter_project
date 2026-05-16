import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/actor_model.dart';
import '../models/user_model.dart';
import '../providers/actor_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/access_denied_body.dart';
import '../widgets/async_value_view.dart';
import '../widgets/responsive_frame.dart';

class AgencyApplicantProfilePage extends ConsumerWidget {
  final String actorId;

  const AgencyApplicantProfilePage({super.key, required this.actorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final profileAsync = ref.watch(actorProfileStreamByIdProvider(actorId));

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
        onRetry: () => ref.invalidate(actorProfileStreamByIdProvider(actorId)),
        isEmpty: (a) => a == null,
        empty: (_) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Text(
              'This actor has not completed a public profile yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant),
            ),
          ),
        ),
        data: (actor) {
          final a = actor!;
          return ResponsiveFrame(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage:
                          a.profileImageUrl != null ? NetworkImage(a.profileImageUrl!) : null,
                      child: a.profileImageUrl == null
                          ? const Icon(Icons.person, size: 56)
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Text(
                    a.fullName.isEmpty ? 'Unnamed actor' : a.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Profile ID: ${a.uid}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _SectionTitle(title: 'Basics'),
                  _InfoRow(label: 'Gender', value: a.gender.isEmpty ? '—' : a.gender),
                  _InfoRow(label: 'Ethnicity', value: a.ethnicity.isEmpty ? '—' : a.ethnicity),
                  _InfoRow(label: 'Age', value: a.age > 0 ? '${a.age}' : '—'),
                  _InfoRow(label: 'Location', value: _formatLocation(a)),
                  _InfoRow(label: 'Height', value: a.height > 0 ? '${a.height} cm' : '—'),
                  _InfoRow(label: 'Weight', value: a.weight > 0 ? '${a.weight} kg' : '—'),
                  const SizedBox(height: AppTheme.spacingMd),
                  _SectionTitle(title: 'Skills'),
                  Text(
                    a.skills.isEmpty ? '—' : a.skills.join(', '),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  _SectionTitle(title: 'Bio'),
                  Text(
                    a.bio.isEmpty ? '—' : a.bio,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
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
