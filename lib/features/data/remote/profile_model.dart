class ProfileModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String type;
  final String password;
  final String? token;

  ProfileModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.type,
    this.token
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email']as String? ?? '',
      password: json['password'] as String? ?? '',
      type: json['type'] as String? ?? 'Transportista',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'type': type,
    };
  }
}
