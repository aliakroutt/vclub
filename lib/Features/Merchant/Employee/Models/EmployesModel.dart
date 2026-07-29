class EmployeeModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  EmployeeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class EmployeesPaginatedResponse {
  final List<EmployeeModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  EmployeesPaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory EmployeesPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return EmployeesPaginatedResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}