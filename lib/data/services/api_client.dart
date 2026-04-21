import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Central API client for communicating with the backend.
class ApiClient {
  static const _productionUrl = 'https://oicoach-production.up.railway.app/api';
  static const _localUrl = 'http://localhost:3000/api';

  /// Use production URL in release mode, localhost in debug.
  static String get _baseUrl => kReleaseMode ? _productionUrl : _localUrl;

  static final _client = http.Client();

  static Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(uri);
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  static Future<void> delete(String path) async {
    final response = await _client.delete(Uri.parse('$_baseUrl$path'));
    _checkResponse(response);
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: body['error'] ?? 'Unknown error',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
