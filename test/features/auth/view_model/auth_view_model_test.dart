import 'package:flutter_test/flutter_test.dart';
import 'package:oi_coach/data/repositories/auth_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';
import 'package:oi_coach/features/auth/view_model/auth_view_model.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// In-memory fake that avoids touching real secure storage.
class FakeTokenService implements TokenService {
  String? storedAccess;
  String? storedRefresh;

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    storedAccess = accessToken;
    storedRefresh = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => storedAccess;

  @override
  Future<String?> getRefreshToken() async => storedRefresh;

  @override
  Future<void> clearTokens() async {
    storedAccess = null;
    storedRefresh = null;
  }

  @override
  Future<bool> hasTokens() async =>
      storedAccess != null && storedRefresh != null;
}

class FakeAuthRepository extends AuthRepository {
  AuthResponse? loginResult;
  AuthResponse? registerResult;
  ApiException? loginError;
  ApiException? registerError;

  FakeAuthRepository(ApiClient client) : super(client);

  @override
  Future<AuthResponse> login(String email, String password) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    if (registerError != null) throw registerError!;
    return registerResult!;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeAuthResponse = AuthResponse(
  accessToken: 'access-123',
  refreshToken: 'refresh-456',
  userId: 'user-1',
  name: 'Test',
  email: 'test@example.com',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeTokenService tokenService;
  late ApiClient apiClient;
  late FakeAuthRepository authRepo;
  late AuthViewModel vm;

  setUp(() {
    tokenService = FakeTokenService();
    apiClient = ApiClient(tokenService);
    authRepo = FakeAuthRepository(apiClient);
    vm = AuthViewModel(
      tokenService: tokenService,
      authRepository: authRepo,
      apiClient: apiClient,
    );
  });

  group('initial state', () {
    test('starts unauthenticated with no loading or error', () {
      expect(vm.isAuthenticated, isFalse);
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
    });
  });

  group('login', () {
    test('sets isAuthenticated and saves tokens on success', () async {
      authRepo.loginResult = _fakeAuthResponse;

      await vm.login('test@example.com', 'password1');

      expect(vm.isAuthenticated, isTrue);
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(tokenService.storedAccess, 'access-123');
      expect(tokenService.storedRefresh, 'refresh-456');
    });

    test('sets error on ApiException', () async {
      authRepo.loginError = const ApiException(
        statusCode: 401,
        message: 'Credenciais inválidas',
      );

      await vm.login('bad@example.com', 'wrong');

      expect(vm.isAuthenticated, isFalse);
      expect(vm.error, 'Credenciais inválidas');
      expect(vm.isLoading, isFalse);
    });

    test('notifies listeners during loading cycle', () async {
      authRepo.loginResult = _fakeAuthResponse;
      final states = <bool>[];
      vm.addListener(() => states.add(vm.isLoading));

      await vm.login('test@example.com', 'password1');

      // First notification: isLoading=true, second: isLoading=false
      expect(states, [true, false]);
    });
  });

  group('register', () {
    test('sets isAuthenticated and saves tokens on success', () async {
      authRepo.registerResult = _fakeAuthResponse;

      await vm.register('Test', 'test@example.com', 'password1');

      expect(vm.isAuthenticated, isTrue);
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(tokenService.storedAccess, 'access-123');
    });

    test('sets error on ApiException', () async {
      authRepo.registerError = const ApiException(
        statusCode: 409,
        message: 'Email já cadastrado',
      );

      await vm.register('Test', 'dup@example.com', 'password1');

      expect(vm.isAuthenticated, isFalse);
      expect(vm.error, 'Email já cadastrado');
    });
  });

  group('logout', () {
    test('clears tokens and sets unauthenticated', () async {
      // First login
      authRepo.loginResult = _fakeAuthResponse;
      await vm.login('test@example.com', 'password1');
      expect(vm.isAuthenticated, isTrue);

      await vm.logout();

      expect(vm.isAuthenticated, isFalse);
      expect(vm.error, isNull);
      expect(tokenService.storedAccess, isNull);
      expect(tokenService.storedRefresh, isNull);
    });
  });

  group('tryRestoreSession', () {
    test('sets authenticated when tokens exist', () async {
      tokenService.storedAccess = 'a';
      tokenService.storedRefresh = 'r';

      await vm.tryRestoreSession();

      expect(vm.isAuthenticated, isTrue);
      expect(vm.isLoading, isFalse);
    });

    test('stays unauthenticated when no tokens', () async {
      await vm.tryRestoreSession();

      expect(vm.isAuthenticated, isFalse);
      expect(vm.isLoading, isFalse);
    });
  });

  group('onSessionExpired callback', () {
    test('ApiClient.onSessionExpired sets unauthenticated', () async {
      authRepo.loginResult = _fakeAuthResponse;
      await vm.login('test@example.com', 'password1');
      expect(vm.isAuthenticated, isTrue);

      // Simulate session expiry from ApiClient
      apiClient.onSessionExpired?.call();

      expect(vm.isAuthenticated, isFalse);
    });
  });
}
