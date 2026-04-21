import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/features/auth/view_model/auth_view_model.dart';

class LoginView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const LoginView({super.key, required this.authViewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthViewModel get _vm => widget.authViewModel;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    await _vm.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'APEX.OS',
                  style: AppTextStyles.display(size: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para continuar',
                  style: AppTextStyles.body(color: AppColors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email field
                Text('EMAIL', style: AppTextStyles.monoLabel()),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enabled: !_vm.isLoading,
                  style: AppTextStyles.body(),
                  decoration: const InputDecoration(hintText: 'seu@email.com'),
                ),
                const SizedBox(height: 20),

                // Password field
                Text('SENHA', style: AppTextStyles.monoLabel()),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !_vm.isLoading,
                  style: AppTextStyles.body(),
                  decoration: const InputDecoration(hintText: '••••••••'),
                ),
                const SizedBox(height: 24),

                // Error message
                if (_vm.error != null) ...[
                  Text(
                    _vm.error!,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.destructive,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit button
                GestureDetector(
                  onTap: _vm.isLoading ? null : _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _vm.isLoading
                          ? AppColors.volt.withValues(alpha: 0.5)
                          : AppColors.volt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryForeground,
                              ),
                            )
                          : Text('ENTRAR', style: AppTextStyles.button()),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register link
                GestureDetector(
                  onTap: _vm.isLoading ? null : () => context.go('/register'),
                  child: Text(
                    'Criar conta',
                    style: AppTextStyles.body(color: AppColors.volt),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
