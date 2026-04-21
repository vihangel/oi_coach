import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/features/auth/view/login_view.dart';
import 'package:oi_coach/features/auth/view/register_view.dart';
import 'package:oi_coach/features/auth/view_model/auth_view_model.dart';
import 'package:oi_coach/features/configuracoes/view/configuracoes_view.dart';
import 'package:oi_coach/features/dashboard/view/dashboard_view.dart';
import 'package:oi_coach/features/fichas/view/fichas_view.dart';
import 'package:oi_coach/features/progresso/view/progresso_view.dart';
import 'package:oi_coach/features/relatorio/view/relatorio_view.dart';
import 'package:oi_coach/features/rotina/view/rotina_view.dart';
import 'package:oi_coach/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Builds the app [GoRouter] wired to [authViewModel] for auth guards.
GoRouter buildRouter(AuthViewModel authViewModel) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final isAuthenticated = authViewModel.isAuthenticated;
      final location = state.uri.toString();
      final isAuthRoute = location == '/login' || location == '/register';

      // Unauthenticated users can only visit /login and /register.
      if (!isAuthenticated && !isAuthRoute) return '/login';

      // Authenticated users should not stay on auth pages.
      if (isAuthenticated && isAuthRoute) return '/';

      return null;
    },
    routes: [
      // Auth routes — outside the ShellRoute (no bottom nav).
      GoRoute(
        path: '/login',
        builder: (_, _) => LoginView(authViewModel: authViewModel),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => RegisterView(authViewModel: authViewModel),
      ),

      // Main app routes — inside the ShellRoute (with bottom nav).
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const DashboardView(),
            routes: [
              GoRoute(
                path: 'relatorio',
                builder: (_, _) => const RelatorioView(),
              ),
              GoRoute(path: 'fichas', builder: (_, _) => const FichasView()),
            ],
          ),
          GoRoute(path: '/rotina', builder: (_, _) => const RotinaView()),
          GoRoute(path: '/progresso', builder: (_, _) => const ProgressoView()),
          GoRoute(
            path: '/configuracoes',
            builder: (_, _) => ConfiguracoesView(authViewModel: authViewModel),
          ),
        ],
      ),
    ],
  );
}
