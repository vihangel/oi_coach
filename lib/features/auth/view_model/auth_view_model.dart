import 'package:flutter/foundation.dart';
import 'package:oi_coach/data/repositories/auth_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';

/// Global authentication state manager.
///
/// Extends [ChangeNotifier] so it can be used as GoRouter's
/// `refreshListenable`, triggering route re-evaluation on auth changes.
class AuthViewModel extends ChangeNotifier {
  final TokenService _tokenService;
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthViewModel({
    required TokenService tokenService,
    required AuthRepository authRepository,
    required ApiClient apiClient,
  }) : _tokenService = tokenService,
       _authRepository = authRepository,
       _apiClient = apiClient {
    _apiClient.onSessionExpired = _onSessionExpired;
  }

  /// Called by [ApiClient] when a token refresh fails.
  void _onSessionExpired() {
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Authenticates with email and password, stores tokens on success.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);
      await _tokenService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      _isAuthenticated = true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Erro inesperado, tente novamente';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new account, stores tokens on success.
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(name, email, password);
      await _tokenService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      _isAuthenticated = true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Erro inesperado, tente novamente';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears tokens and sets state to unauthenticated.
  Future<void> logout() async {
    await _tokenService.clearTokens();
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Checks for existing tokens on app startup and restores session.
  Future<void> tryRestoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasTokens = await _tokenService.hasTokens();
      _isAuthenticated = hasTokens;
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
