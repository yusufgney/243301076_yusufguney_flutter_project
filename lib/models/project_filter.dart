import 'package:flutter/foundation.dart';

@immutable
class ProjectFilter {
  final String? city;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFilter &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          gender == other.gender &&
          ageMin == other.ageMin &&
          ageMax == other.ageMax &&
          listEquals(skills, other.skills);

  @override
  int get hashCode =>
      city.hashCode ^
      gender.hashCode ^
      ageMin.hashCode ^
      ageMax.hashCode ^
      skills.hashCode;
}
