import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/actor_model.dart';
import '../providers/actor_provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/project_filter_provider.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/application_status_chip.dart';
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
    return Scaffold(
      body: const [
        _ProjectsTab(),
        _MyApplicationsTab(),
        _ProfileTab(),
        _SettingsTab(),
      ][_selectedIndex],
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
          Consumer(
            builder: (context, ref, child) {
              final hasFilter = ref.watch(projectFilterProvider.select((f) => f.hasAnyActive));
              if (!hasFilter) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.filter_alt, size: 18, color: theme.colorScheme.primary),
                ),
              );
            },
          ),
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
            return const AppEmptyState(
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
            return const AppEmptyState(
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
                        ApplicationStatusChip(status: app.status),
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
            return AppEmptyState(
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
          Text(_formatLocation(profile),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingLg),

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

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'Gender', value: profile.gender),
                  _DetailRow(label: 'Ethnicity', value: profile.ethnicity.isEmpty ? '—' : profile.ethnicity),
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

  String _formatLocation(ActorModel a) {
    if (a.city.isEmpty && a.country.isEmpty) return '—';
    if (a.city.isEmpty) return a.country;
    if (a.country.isEmpty) return a.city;
    return '${a.country}, ${a.city}';
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userModelProvider).value;
    final authCtrl = ref.watch(authControllerProvider);
    final email = userModel?.email ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
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
                  title: Consumer(builder: (context, ref, _) {
                    final profile = ref.watch(actorProfileProvider).value;
                    return Text(profile == null ? 'Create Profile' : 'Edit Profile');
                  }),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/edit-actor-profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text('Preferences', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Card(
            child: Consumer(builder: (context, ref, _) {
              final themeMode = ref.watch(themeModeProvider);
              final isDark = themeMode == ThemeMode.dark;
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
          Text('Account Actions', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              title: Text(
                'Sign Out',
                style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error),
              ),
              onTap: authCtrl.isLoading ? null : () => _showLogoutConfirmation(context, ref),
              trailing: authCtrl.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd, horizontal: 4),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
            ),
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

