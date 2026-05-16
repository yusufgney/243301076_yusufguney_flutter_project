enum ApplicationStatus { pending, accepted, rejected }

class ApplicationModel {
  final String id;
  final String projectId;
  final String actorId;
  final ApplicationStatus status;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.projectId,
    required this.actorId,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ApplicationModel(
      id: documentId,
      projectId: map['projectId'] as String? ?? '',
      actorId: map['actorId'] as String? ?? '',
      status: _stringToStatus(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'actorId': actorId,
      'status': statusToString(status),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ApplicationStatus _stringToStatus(String? status) => switch (status) {
    'accepted' => ApplicationStatus.accepted,
    'rejected' => ApplicationStatus.rejected,
    _ => ApplicationStatus.pending,
  };

  static String statusToString(ApplicationStatus status) {
    return status.name;
  }
}
