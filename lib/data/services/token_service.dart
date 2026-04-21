import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper over [FlutterSecureStorage] for persisting JWT tokens.
class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Persists both tokens to secure storage.
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Returns the stored access token, or `null` if absent.
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  /// Returns the stored refresh token, or `null` if absent.
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  /// Removes both tokens from secure storage.
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  /// Returns `true` if both tokens are present in storage.
  Future<bool> hasTokens() async {
    final access = await _storage.read(key: _accessTokenKey);
    final refresh = await _storage.read(key: _refreshTokenKey);
    return access != null && refresh != null;
  }
}
