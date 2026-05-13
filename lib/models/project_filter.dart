import 'package:flutter/foundation.dart';

/// Firestore-backed filter criteria for casting projects.
@immutable
class ProjectFilter {
  final String? city;
  /// `Any`, `Male`, or `Female` — matches stored `genderRequirement`.
  final String gender;
  final int? ageMin;
  final int? ageMax;
  final List<String> skills;

  const ProjectFilter({
    this.city,
    this.gender = 'Any',
    this.ageMin,
    this.ageMax,
    this.skills = const [],
  });

  ProjectFilter copyWith({
    String? city,
    String? gender,
    int? ageMin,
    int? ageMax,
    List<String>? skills,
    bool clearCity = false,
    bool clearAge = false,
    bool clearSkills = false,
  }) {
    return ProjectFilter(
      city: clearCity ? null : (city ?? this.city),
      gender: gender ?? this.gender,
      ageMin: clearAge ? null : (ageMin ?? this.ageMin),
      ageMax: clearAge ? null : (ageMax ?? this.ageMax),
      skills: clearSkills ? const [] : (skills ?? this.skills),
    );
  }

  bool get hasAgeFilter =>
      ageMin != null && ageMax != null && ageMin! <= ageMax!;

  bool get hasActiveCity => city != null && city!.trim().isNotEmpty;

  bool get hasActiveGender => gender != 'Any';

  bool get hasActiveSkills => skills.isNotEmpty;

  bool get hasAnyActive =>
      hasActiveCity || hasActiveGender || hasAgeFilter || hasActiveSkills;
}
