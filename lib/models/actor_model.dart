class ActorModel {
  final String uid;
  final String fullName;
  final String gender;
  final int age;
  final String city;
  final double height;
  final double weight;
  final List<String> skills;
  final String bio;
  final String? profileImageUrl;

  ActorModel({
    required this.uid,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.city,
    required this.height,
    required this.weight,
    required this.skills,
    required this.bio,
    this.profileImageUrl,
  });

  factory ActorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ActorModel(
      uid: documentId,
      fullName: map['fullName'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      city: map['city'] as String? ?? '',
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      skills: List<String>.from(map['skills'] ?? []),
      bio: map['bio'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'city': city,
      'height': height,
      'weight': weight,
      'skills': skills,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }

  ActorModel copyWith({
    String? fullName,
    String? gender,
    int? age,
    String? city,
    double? height,
    double? weight,
    List<String>? skills,
    String? bio,
    String? profileImageUrl,
  }) {
    return ActorModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      city: city ?? this.city,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
