class AgencyModel {
  final String uid;
  final String agencyName;
  final String city;
  final String description;
  final String contactEmail;

  AgencyModel({
    required this.uid,
    required this.agencyName,
    required this.city,
    required this.description,
    required this.contactEmail,
  });

  factory AgencyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AgencyModel(
      uid: documentId,
      agencyName: map['agencyName'] as String? ?? '',
      city: map['city'] as String? ?? '',
      description: map['description'] as String? ?? '',
      contactEmail: map['contactEmail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'agencyName': agencyName,
      'city': city,
      'description': description,
      'contactEmail': contactEmail,
    };
  }

  AgencyModel copyWith({
    String? agencyName,
    String? city,
    String? description,
    String? contactEmail,
  }) {
    return AgencyModel(
      uid: uid,
      agencyName: agencyName ?? this.agencyName,
      city: city ?? this.city,
      description: description ?? this.description,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }
}
