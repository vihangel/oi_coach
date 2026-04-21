import 'dart:convert';

import 'package:oi_coach/data/services/api_client.dart';

/// Response model for authentication endpoints.
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String email;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.email,
  });

  /// Parses the API JSON response into an [AuthResponse].
  ///
  /// The backend returns `{ accessToken, refreshToken }`. User info
  /// (userId, email) is extracted from the JWT payload. Because the
  /// login endpoint does not return the user's name, [fallbackName]
  /// can be supplied (e.g. from the register form input).
  factory AuthResponse.fromJson(
    Map<String, dynamic> json, {
    String fallbackName = '',
  }) {
    final accessToken = json['accessToken'] as String;
    final refreshToken = json['refreshToken'] as String;
    final payload = _decodeJwtPayload(accessToken);

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: payload['userId'] as String,
      name: fallbackName,
      email: payload['email'] as String,
    );
  }

  /// Decodes the payload section of a JWT without verifying the signature.
  static Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format');
    }
    final payload = parts[1];
    // JWT base64url may need padding
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}

/// Repository for authentication API calls.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Authenticates a user with email and password.
  Future<AuthResponse> login(String email, String password) async {
    final json = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(json as Map<String, dynamic>);
  }

  /// Registers a new user account.
  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final json = await _apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(
      json as Map<String, dynamic>,
      fallbackName: name,
    );
  }

  /// Exchanges a refresh token for a new token pair.
  Future<AuthResponse> refresh(String refreshToken) async {
    final json = await _apiClient.post('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return AuthResponse.fromJson(json as Map<String, dynamic>);
  }
}
