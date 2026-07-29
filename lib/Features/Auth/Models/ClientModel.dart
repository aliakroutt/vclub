class ClientProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime? birthday;
  final String? avatar;
  final String? language;
  final bool isActive;

  ClientProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.birthday,
    this.avatar,
    this.language,
    this.isActive = true,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'].toString())
          : null,
      avatar: json['avatar']?.toString(),
      language: json['language']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'birthday': birthday?.toIso8601String(),
    'avatar': avatar,
    'language': language,
    'isActive': isActive,
  };
}
}