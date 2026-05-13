import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_filter.dart';
import 'auth_provider.dart';

/// Current project list filters (Firestore query).
final projectFilterProvider =
    NotifierProvider<ProjectFilterNotifier, ProjectFilter>(
  ProjectFilterNotifier.new,
);

class ProjectFilterNotifier extends Notifier<ProjectFilter> {
  @override
  ProjectFilter build() => const ProjectFilter();

  void setFilter(ProjectFilter filter) => state = filter;

  void clear() => state = const ProjectFilter();
}

/// Builds a [Query] for `casting_projects` using Firestore `where` clauses.
///
/// Composite indexes may be required when combining filters with
/// `orderBy('createdAt')`. The console / SDK error usually includes a link
/// to create the missing index.
final filteredProjectsQueryProvider =
    Provider<Query<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firestoreProvider);
  final filter = ref.watch(projectFilterProvider);

  Query<Map<String, dynamic>> q = db.collection('casting_projects');

  if (filter.hasActiveCity) {
    q = q.where('city', isEqualTo: filter.city!.trim());
  }

  if (filter.hasActiveGender) {
    q = q.where(
      'genderRequirement',
      whereIn: <String>[filter.gender, 'Any'],
    );
  }

  if (filter.hasAgeFilter) {
    q = q.where('ageMin', isLessThanOrEqualTo: filter.ageMax!);
    q = q.where('ageMax', isGreaterThanOrEqualTo: filter.ageMin!);
  }

  if (filter.hasActiveSkills) {
    final list = filter.skills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (list.length == 1) {
      q = q.where('skillsRequired', arrayContains: list.first);
    } else {
      q = q.where(
        'skillsRequired',
        arrayContainsAny: list.take(10).toList(),
      );
    }
  }

  q = q.orderBy('createdAt', descending: true);
  return q;
});
