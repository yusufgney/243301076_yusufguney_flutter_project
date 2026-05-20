import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_frame.dart';

class CreateProjectPage extends ConsumerStatefulWidget {
  final String? projectId;
  final ProjectModel? initialProject;

  const CreateProjectPage({
    super.key,
    this.projectId,
    this.initialProject,
  });

  @override
  ConsumerState<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends ConsumerState<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageMinController = TextEditingController();
  final _ageMaxController = TextEditingController();
  final _skillsController = TextEditingController();

  bool _isSaving = false;
  bool _isLoadingProject = false;
  String _genderRequirement = 'Any';

  @override
  void initState() {
    super.initState();
    if (widget.initialProject != null) {
      _populateFields(widget.initialProject!);
    } else if (widget.projectId != null) {
      _loadProject();
    }
  }

  void _populateFields(ProjectModel p) {
    _titleController.text = p.title;
    _descriptionController.text = p.description;
    _cityController.text = p.city;
    _genderRequirement = p.genderRequirement;
    _ageMinController.text = p.ageMin.toString();
    _ageMaxController.text = p.ageMax.toString();
    _skillsController.text = p.skillsRequired.join(', ');
  }

  Future<void> _loadProject() async {
    setState(() => _isLoadingProject = true);
    try {
      final doc = await ref
          .read(firestoreProvider)
          .collection('casting_projects')
          .doc(widget.projectId)
          .get();
      if (doc.exists && doc.data() != null) {
        final p = ProjectModel.fromMap(doc.data()!, doc.id);
        _populateFields(p);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProject = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return;
    }

    final ageMin = int.parse(_ageMinController.text.trim());
    final ageMax = int.parse(_ageMaxController.text.trim());

    if (ageMin > ageMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Age Min cannot be greater than Age Max.')),
      );
      return;
    }

    final skills = _skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() => _isSaving = true);

    try {
      final isEdit = widget.projectId != null;
      final projectsRef = ref.read(firestoreProvider).collection('casting_projects');
      final docRef = isEdit ? projectsRef.doc(widget.projectId) : projectsRef.doc();

      final project = ProjectModel(
        id: docRef.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        genderRequirement: _genderRequirement,
        ageMin: ageMin,
        ageMax: ageMax,
        skillsRequired: skills,
        createdBy: user.uid,
        createdAt: isEdit && widget.initialProject != null
            ? widget.initialProject!.createdAt
            : DateTime.now(),
      );

      await docRef.set(project.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Project updated successfully.' : 'Project created successfully.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save project: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.projectId != null;
    final pageTitle = isEdit ? 'Edit Casting Project' : 'Create Casting Project';
    final buttonLabel = isEdit ? 'Save Changes' : 'Create Project';

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: _isLoadingProject
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveFrame(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 4,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'City is required' : null,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      DropdownButtonFormField<String>(
                        initialValue: _genderRequirement,
                        decoration: const InputDecoration(labelText: 'Gender Requirement'),
                        items: const [
                          DropdownMenuItem(value: 'Any', child: Text('Any')),
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _genderRequirement = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageMinController,
                              decoration: const InputDecoration(labelText: 'Age Min'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return int.tryParse(value.trim()) == null ? 'Invalid number' : null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: TextFormField(
                              controller: _ageMaxController,
                              decoration: const InputDecoration(labelText: 'Age Max'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return int.tryParse(value.trim()) == null ? 'Invalid number' : null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      TextFormField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          labelText: 'Skills Required',
                          hintText: 'Camera, Acting, Dance',
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProject,
                        child: _isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(buttonLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
