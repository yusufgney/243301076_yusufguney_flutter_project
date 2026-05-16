import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Open project ${project.title}',
      child: Card(
        child: InkWell(
          borderRadius: AppTheme.borderRadiusLg,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Wrap(
                  spacing: AppTheme.spacingXs,
                  runSpacing: AppTheme.spacingXs,
                  children: [
                    _MetaChip(icon: Icons.location_on_outlined, label: project.city),
                    _MetaChip(
                      icon: Icons.badge_outlined,
                      label: '${project.ageMin}-${project.ageMax}',
                    ),
                    _MetaChip(icon: Icons.wc_outlined, label: project.genderRequirement),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Skills: ${project.skillsRequired.isEmpty ? "Not specified" : project.skillsRequired.join(", ")}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppTheme.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppTheme.spacingXs),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
