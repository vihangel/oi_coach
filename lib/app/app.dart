import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/data/repositories/auth_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';
import 'package:oi_coach/features/auth/view_model/auth_view_model.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class ApexApp extends StatefulWidget {
  const ApexApp({super.key});

  @override
  State<ApexApp> createState() => _ApexAppState();
}

class _ApexAppState extends State<ApexApp> {
  late final TokenService _tokenService;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tokenService = TokenService();
    _apiClient = ApiClient(_tokenService);
    _authRepository = AuthRepository(_apiClient);
    _authViewModel = AuthViewModel(
      tokenService: _tokenService,
      authRepository: _authRepository,
      apiClient: _apiClient,
    );
    _router = buildRouter(_authViewModel);
    _init();
  }

  Future<void> _init() async {
    await _authViewModel.tryRestoreSession();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      title: 'Apex.OS',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
