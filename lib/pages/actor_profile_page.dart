import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/actor_model.dart';
import '../providers/actor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/async_value_view.dart';
import '../widgets/responsive_frame.dart';

class ActorProfilePage extends ConsumerWidget {
  const ActorProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(actorProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-actor-profile'),
          ),
        ],
      ),
      body: AsyncValueView<ActorModel?>(
        value: profileState,
        loadingMessage: 'Loading profile…',
        onRetry: () => ref.invalidate(actorProfileProvider),
        isEmpty: (profile) => profile == null,
        empty: (_) => AppEmptyState(
          icon: Icons.person_outline_rounded,
          title: 'Profile incomplete',
          message: 'Add your headshot, experience and skills so agencies can find you.',
          actionLabel: 'Create profile',
          onAction: () => context.push('/edit-actor-profile'),
        ),
        data: (profile) {
          final p = profile!;
          return ResponsiveFrame(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: p.profileImageUrl != null
                          ? NetworkImage(p.profileImageUrl!)
                          : null,
                      child: p.profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildInfoRow(context, 'Full Name', p.fullName),
                  _buildInfoRow(context, 'Gender', p.gender),
                  _buildInfoRow(context, 'Age', p.age.toString()),
                  _buildInfoRow(context, 'City', p.city),
                  _buildInfoRow(context, 'Height', '${p.height} cm'),
                  _buildInfoRow(context, 'Weight', '${p.weight} kg'),
                  _buildInfoRow(context, 'Skills', p.skills.join(', ')),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text('Bio', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(p.bio, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
