import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/actor_model.dart';
import '../providers/actor_provider.dart';
import '../providers/auth_provider.dart';

class EditActorProfilePage extends ConsumerStatefulWidget {
  const EditActorProfilePage({super.key});

  @override
  ConsumerState<EditActorProfilePage> createState() => _EditActorProfilePageState();
}

class _EditActorProfilePageState extends ConsumerState<EditActorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _cityController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _skillsController;
  late TextEditingController _bioController;
  
  String _gender = 'Male';
  Uint8List? _imageBytes;
  String? _imageExtension;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _ageController = TextEditingController();
    _cityController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _skillsController = TextEditingController();
    _bioController = TextEditingController();

    // Load existing profile if it exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(actorProfileProvider).value;
      if (profile != null) {
        setState(() {
          _fullNameController.text = profile.fullName;
          _gender = profile.gender.isNotEmpty ? profile.gender : 'Male';
          _ageController.text = profile.age.toString();
          _cityController.text = profile.city;
          _heightController.text = profile.height.toString();
          _weightController.text = profile.weight.toString();
          _skillsController.text = profile.skills.join(', ');
          _bioController.text = profile.bio;
          _existingImageUrl = profile.profileImageUrl;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _skillsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageExtension = pickedFile.name.split('.').last;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final profile = ActorModel(
      uid: user.uid,
      fullName: _fullNameController.text,
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 0,
      city: _cityController.text,
      height: double.tryParse(_heightController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      skills: _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      bio: _bioController.text,
      profileImageUrl: _existingImageUrl,
    );

    await ref.read(actorProfileControllerProvider.notifier).saveProfile(
      profile: profile,
      imageBytes: _imageBytes,
      imageExtension: _imageExtension,
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(actorProfileControllerProvider).isLoading;

    ref.listen(actorProfileControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar ──────────────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundImage: _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : (_existingImageUrl != null
                                      ? NetworkImage(_existingImageUrl!) as ImageProvider
                                      : null),
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: _imageBytes == null && _existingImageUrl == null
                                  ? Icon(Icons.person, size: 48,
                                      color: Theme.of(context).colorScheme.outline)
                                  : null,
                            ),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Tap to change photo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Personal Info ────────────────────────────────────────
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.wc_outlined),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Physical Stats ───────────────────────────────────────
                    Text(
                      'Physical Stats',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              prefixIcon: Icon(Icons.height_outlined),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(Icons.monitor_weight_outlined),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Skills & Bio ─────────────────────────────────────────
                    Text(
                      'Skills & Bio',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills',
                        hintText: 'Acting, Dancing, Singing…',
                        prefixIcon: Icon(Icons.star_outline),
                        helperText: 'Separate multiple skills with commas',
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell agencies about yourself…',
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),

                    const SizedBox(height: 32),

                    // ── Save Button ──────────────────────────────────────────
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
