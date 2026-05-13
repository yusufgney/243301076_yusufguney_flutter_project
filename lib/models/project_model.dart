class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String city;
  final String genderRequirement;
  final int ageMin;
  final int ageMax;
  final List<String> skillsRequired;
  final String createdBy;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.genderRequirement,
    required this.ageMin,
    required this.ageMax,
    required this.skillsRequired,
    required this.createdBy,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProjectModel(
      id: documentId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      city: map['city'] as String? ?? '',
      genderRequirement: map['genderRequirement'] as String? ?? 'Any',
      ageMin: map['ageMin'] as int? ?? 0,
      ageMax: map['ageMax'] as int? ?? 99,
      skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'city': city,
      'genderRequirement': genderRequirement,
      'ageMin': ageMin,
      'ageMax': ageMax,
      'skillsRequired': skillsRequired,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
