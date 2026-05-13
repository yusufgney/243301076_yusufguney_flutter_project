import 'package:flutter/material.dart';

import '../models/project_filter.dart';
import '../theme/app_theme.dart';

typedef ProjectFilterCallback = void Function(ProjectFilter filter);

/// Shared filter fields used by the bottom sheet and full-screen filter page.
class ProjectFilterForm extends StatefulWidget {
  final ProjectFilter initial;
  final ProjectFilterCallback onApply;
  const ProjectFilterForm({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<ProjectFilterForm> createState() => _ProjectFilterFormState();
}

class _ProjectFilterFormState extends State<ProjectFilterForm> {
  late final TextEditingController _cityController;
  late final TextEditingController _ageMinController;
  late final TextEditingController _ageMaxController;
  late final TextEditingController _skillsController;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initial.city ?? '');
    _ageMinController = TextEditingController(
      text: widget.initial.ageMin?.toString() ?? '',
    );
    _ageMaxController = TextEditingController(
      text: widget.initial.ageMax?.toString() ?? '',
    );
    _skillsController = TextEditingController(
      text: widget.initial.skills.join(', '),
    );
    _gender = widget.initial.gender;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _apply() {
    int? ageMin;
    int? ageMax;
    final minText = _ageMinController.text.trim();
    final maxText = _ageMaxController.text.trim();
    if (minText.isNotEmpty) {
      ageMin = int.tryParse(minText);
    }
    if (maxText.isNotEmpty) {
      ageMax = int.tryParse(maxText);
    }

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final filter = ProjectFilter(
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      gender: _gender,
      ageMin: ageMin,
      ageMax: ageMax,
      skills: skills,
    );

    if (filter.ageMin != null &&
        filter.ageMax != null &&
        filter.ageMin! > filter.ageMax!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Age min cannot be greater than age max.')),
      );
      return;
    }

    widget.onApply(filter);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filters', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingMd),
          Semantics(
            label: 'City filter',
            child: TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'Exact match',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Semantics(
            label: 'Gender requirement filter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gender', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppTheme.spacingSm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Any', label: Text('Any')),
                    ButtonSegment(value: 'Male', label: Text('Male')),
                    ButtonSegment(value: 'Female', label: Text('Female')),
                  ],
                  selected: {_gender},
                  emptySelectionAllowed: false,
                  onSelectionChanged: (Set<String> selection) {
                    if (selection.isEmpty) return;
                    setState(() => _gender = selection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Age range (overlap)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Shows projects whose casting ages overlap this range.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Minimum age filter',
                  child: TextField(
                    controller: _ageMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min age',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Semantics(
                  label: 'Maximum age filter',
                  child: TextField(
                    controller: _ageMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max age',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Semantics(
            label: 'Skills filter comma separated',
            child: TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills',
                hintText: 'Acting, Dance (comma-separated)',
                prefixIcon: Icon(Icons.construction_outlined),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Semantics(
            button: true,
            label: 'Apply filters',
            child: FilledButton(
              onPressed: _apply,
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
