import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/agency_model.dart';
import '../models/project_model.dart';
import '../providers/agency_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/application_provider.dart';
import '../providers/project_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class AgencyDashboardPage extends ConsumerStatefulWidget {
  const AgencyDashboardPage({super.key});

  @override
  ConsumerState<AgencyDashboardPage> createState() => _AgencyDashboardPageState();
}

class _AgencyDashboardPageState extends ConsumerState<AgencyDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _ProjectsTab(),
          _ProfileTab(),
          _SettingsTab(),
        ],
      ),
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
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
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
    final projectsAsync = ref.watch(agencyProjectsProvider);
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
              child: Text('cast',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            Text('flow',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => context.push('/create-project'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Project'),
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyHero(
              icon: Icons.work_outline_rounded,
              title: 'No projects yet',
              message: 'Create your first casting call to find talent.',
              actionLabel: 'Create Project',
              onAction: () => context.push('/create-project'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: projects.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
            itemBuilder: (context, i) => _AgencyProjectCard(project: projects[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AgencyProjectCard extends ConsumerWidget {
  final ProjectModel project;
  const _AgencyProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countAsync = ref.watch(projectApplicationCountProvider(project.id));
    final applicantCount = countAsync.maybeWhen(data: (c) => c, orElse: () => 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(project.title, style: theme.textTheme.titleMedium),
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Badge(
                  isLabelVisible: applicantCount > 0,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  label: Text(
                    applicantCount > 99 ? '99+' : '$applicantCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/project-applicants/${project.id}'),
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Applicants'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXs),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  tooltip: 'Details',
                  onPressed: () => context.push('/project-detail/${project.id}', extra: project),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    side: const BorderSide(color: AppTheme.outline),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusSm),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: AppTheme.spacingXs,
              children: [
                _MetaChip(Icons.location_on_outlined, project.city),
                _MetaChip(Icons.wc_outlined, project.genderRequirement),
                _MetaChip(Icons.person_outline_rounded, '${project.ageMin}–${project.ageMax} yrs'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
      label: Text(label),
      padding: EdgeInsets.zero,
    );
  }
}

// ─── Profile Tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends ConsumerStatefulWidget {
  const _ProfileTab();

  @override
  ConsumerState<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<_ProfileTab> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController();
  late final _cityCtrl = TextEditingController();
  late final _emailCtrl = TextEditingController();
  late final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _populate(AgencyModel p) {
    _nameCtrl.text = p.agencyName;
    _cityCtrl.text = p.city;
    _emailCtrl.text = p.contactEmail;
    _descCtrl.text = p.description;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    final model = AgencyModel(
      uid: uid,
      agencyName: _nameCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    await ref.read(agencyProfileControllerProvider.notifier).saveProfile(model);
    if (mounted) setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(agencyProfileProvider);
    final isSaving = ref.watch(agencyProfileControllerProvider).isLoading;
    final theme = Theme.of(context);

    ref.listen(agencyProfileProvider, (_, next) {
      if (next.value != null && !_isEditing) _populate(next.value!);
    });
    ref.listen(agencyProfileControllerProvider, (_, s) {
      if (s.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Agency Profile'),
        actions: profileAsync.value != null && !_isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () {
                    _populate(profileAsync.value!);
                    setState(() => _isEditing = true);
                  },
                ),
              ]
            : null,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (_isEditing || profile == null) return _buildForm(isSaving, profile != null);
          return _buildView(context, profile, theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildView(BuildContext context, AgencyModel p, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppTheme.borderRadiusLg,
                    ),
                    child: const Icon(Icons.business_rounded, size: 36, color: AppTheme.primary),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(p.agencyName, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(p.city, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(p.contactEmail, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          if (p.description.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(p.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isSaving, bool canCancel) {
    final theme = Theme.of(context);
    return isSaving
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!canCancel) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        child: Column(
                          children: [
                            const Icon(Icons.business_outlined, size: 36, color: AppTheme.primary),
                            const SizedBox(height: AppTheme.spacingXs),
                            Text('Set up your agency profile',
                                style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text('This helps actors find you.',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                  ],
                  _FormField(controller: _nameCtrl, label: 'Agency Name', required: true),
                  const SizedBox(height: AppTheme.spacingMd),
                  _FormField(controller: _cityCtrl, label: 'City', required: true),
                  const SizedBox(height: AppTheme.spacingMd),
                  _FormField(
                    controller: _emailCtrl,
                    label: 'Contact Email',
                    required: true,
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  _FormField(
                    controller: _descCtrl,
                    label: 'Description (optional)',
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  ElevatedButton(onPressed: _save, child: const Text('Save Profile')),
                  if (canCancel) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
          );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────
class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.watch(authControllerProvider);
    final userModel = ref.watch(userModelProvider).value;
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
                  subtitle: Text(userModel?.email ?? '—'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
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
          Text('Account Actions',
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppTheme.spacingXs),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              title: Text('Sign Out',
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error)),
              onTap: authCtrl.isLoading
                  ? null
                  : () => ref.read(authControllerProvider.notifier).logout(),
              trailing: authCtrl.isLoading
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Form Field ───────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;
  final TextInputType keyboard;

  const _FormField({
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
    );
  }
}

// ─── Shared Empty Hero ────────────────────────────────────────────────────────
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
                  color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingXs),
            Text(message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
