import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:oi_coach/data/services/token_service.dart';

/// Central API client for communicating with the backend.
///
/// Instance-based: requires a [TokenService] for JWT token management.
/// Automatically attaches Bearer tokens and handles 401 refresh.
class ApiClient {
  static const _productionUrl = 'https://oicoach-production.up.railway.app/api';
  static const _localUrl = 'http://localhost:3000/api';

  /// Always use production URL. Switch to _localUrl only when running
  /// the backend locally (uncomment the line below).
  static String get _baseUrl => _productionUrl;
  // static String get _baseUrl => kReleaseMode ? _productionUrl : _localUrl;

  final TokenService _tokenService;
  final http.Client _client;

  /// Called when a token refresh fails — the session is expired.
  VoidCallback? onSessionExpired;

  ApiClient(this._tokenService, {http.Client? client})
    : _client = client ?? http.Client();

  /// Builds the default headers including Authorization if a token exists.
  Future<Map<String, String>> _headers({bool json = false}) async {
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParams);
    final headers = await _headers();
    final response = await _client.get(uri, headers: headers);
    return _handleResponse(response, () => get(path, queryParams: queryParams));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers(json: true);
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response, () => post(path, body));
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final headers = await _headers(json: true);
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response, () => put(path, body));
  }

  Future<void> delete(String path) async {
    final headers = await _headers();
    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
    );
    await _handleResponse(response, () => delete(path));
  }

  /// Handles the HTTP response. On 401 with "Token expirado", attempts a
  /// single token refresh and retries [retry]. If refresh fails, clears
  /// tokens and invokes [onSessionExpired].
  Future<dynamic> _handleResponse(
    http.Response response,
    Future<dynamic> Function() retry,
  ) async {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      final message = body['error'] ?? 'Unknown error';

      // Intercept expired-token 401 and try a transparent refresh.
      if (response.statusCode == 401 && message == 'Token expirado') {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          return retry();
        }
        // Refresh failed — session is gone.
        return null;
      }

      throw ApiException(statusCode: response.statusCode, message: message);
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns `true` if new tokens were saved, `false` otherwise.
  Future<bool> _tryRefresh() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) {
      await _handleSessionExpired();
      return false;
    }

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _tokenService.saveTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }
    } catch (_) {
      // Network or parse error during refresh — treat as failure.
    }

    await _handleSessionExpired();
    return false;
  }

  Future<void> _handleSessionExpired() async {
    await _tokenService.clearTokens();
    onSessionExpired?.call();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
