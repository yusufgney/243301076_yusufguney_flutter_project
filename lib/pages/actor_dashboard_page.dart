import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/actor_model.dart';
import '../providers/actor_provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/project_card.dart';

class ActorDashboardPage extends ConsumerStatefulWidget {
  const ActorDashboardPage({super.key});

  @override
  ConsumerState<ActorDashboardPage> createState() => _ActorDashboardPageState();
}

class _ActorDashboardPageState extends ConsumerState<ActorDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userEmail = ref.watch(userModelProvider).value?.email ?? '';

    final pages = [
      const _ProjectsTab(),
      const _MyApplicationsTab(),
      const _ProfileTab(),
      _SettingsTab(email: userEmail),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildNav(context),
    );
  }

  Widget _buildNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.8)),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── Projects Tab ─────────────────────────────────────────────────────────────
class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: AppTheme.borderRadiusSm,
              ),
              child: Text(
                'cast',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'flow',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: () => context.push('/project-filters'),
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyHero(
              icon: Icons.work_outline_rounded,
              title: 'No casting calls yet',
              message: 'Check back later — agencies will post roles here.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final padding = isWide ? AppTheme.spacingXl : AppTheme.spacingMd;
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(padding, AppTheme.spacingMd, padding, 100),
                itemCount: projects.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
                itemBuilder: (context, i) => ProjectCard(
                  project: projects[i],
                  onTap: () => context.push('/project-detail/${projects[i].id}', extra: projects[i]),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ─── My Applications Tab ──────────────────────────────────────────────────────
class _MyApplicationsTab extends ConsumerWidget {
  const _MyApplicationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(actorApplicationsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return _EmptyHero(
              icon: Icons.assignment_outlined,
              title: 'No applications yet',
              message: 'Apply to casting calls — your submissions will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: applications.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
            itemBuilder: (context, i) {
              final app = applications[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingXs,
                  ),
                  title: Text(
                    'Project: ${app.projectId.substring(0, 8)}…',
                    style: theme.textTheme.titleSmall,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        _StatusBadge(status: app.status),
                        const SizedBox(width: AppTheme.spacingXs),
                        Text(
                          _formatDate(app.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => context.push('/project-detail/${app.projectId}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ─── Profile Tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(actorProfileProvider);

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () => context.push('/edit-actor-profile'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return _EmptyHero(
              icon: Icons.person_outline_rounded,
              title: 'Profile incomplete',
              message: 'Create your profile so agencies can discover you.',
              actionLabel: 'Create Profile',
              onAction: () => context.push('/edit-actor-profile'),
            );
          }
          return _ActorProfileView(profile: profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ActorProfileView extends StatelessWidget {
  final ActorModel profile;
  const _ActorProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd, AppTheme.spacingLg, AppTheme.spacingMd, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 52,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? Text(
                    profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                    style: theme.textTheme.headlineMedium?.copyWith(color: AppTheme.primary),
                  )
                : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(profile.fullName, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(profile.city, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingLg),

          // Stats row
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Age', value: '${profile.age}')),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(child: _StatCard(label: 'Height', value: '${profile.height} cm')),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(child: _StatCard(label: 'Weight', value: '${profile.weight} kg')),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'Gender', value: profile.gender),
                  const Divider(),
                  _DetailRow(
                    label: 'Skills',
                    value: profile.skills.isNotEmpty ? profile.skills.join(', ') : '—',
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const Divider(),
                    Text('Bio', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(profile.bio, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────
class _SettingsTab extends ConsumerWidget {
  final String email;
  const _SettingsTab({required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // Account section
          Text('Account', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.email_outlined, color: theme.colorScheme.onSurfaceVariant),
                  title: const Text('Email Address'),
                  subtitle: Text(email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/edit-actor-profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          // Preferences section
          Text('Preferences', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Card(
            child: Consumer(builder: (context, ref, _) {
              final themeModeAsync = ref.watch(themeModeProvider);
              final isDark = themeModeAsync.value == ThemeMode.dark;
              return SwitchListTile(
                secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.onSurfaceVariant),
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).setMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              );
            }),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          // Danger zone
          Text('Account Actions', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              title: Text(
                'Sign Out',
                style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error),
              ),
              onTap: authCtrl.isLoading ? null : () => ref.read(authControllerProvider.notifier).logout(),
              trailing: authCtrl.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Helpers ───────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd, horizontal: AppTheme.spacingSm),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final dynamic status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status.toString().split('.').last;
    Color color;
    if (label == 'accepted') {
      color = AppTheme.success;
    } else if (label == 'rejected') {
      color = AppTheme.error;
    } else {
      color = AppTheme.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppTheme.borderRadiusSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyHero({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingXs),
            Text(message,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
