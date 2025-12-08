class SignupRequest {
  final String accountId;
  final String password;
  final String name;

  SignupRequest({
    required this.accountId,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'password': password,
        'name': name,
      };
}

class LoginRequest {
  final String accountId;
  final String password;

  LoginRequest({
    required this.accountId,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'password': password,
      };
}

class AuthResponse {
  final String token;
  final int userId;
  final String name;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.name,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'],
        userId: json['userId'],
        name: json['name'],
      );
}
