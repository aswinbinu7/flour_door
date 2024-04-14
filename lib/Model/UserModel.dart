class UserModel {
  int? user_id;
  String user_name;
  String email;
  String password;

  UserModel({
    this.user_id,
    required this.user_name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'user_id': user_id,
      'user_name': user_name,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      user_id: map['user_id'] as int?, // Correct type for user_id
      user_name: map['user_name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'user_name': user_name,
      'email': email,
      'password': password,
    };
  }
}
