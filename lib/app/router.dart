import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/features/configuracoes/view/configuracoes_view.dart';
import 'package:oi_coach/features/dashboard/view/dashboard_view.dart';
import 'package:oi_coach/features/fichas/view/fichas_view.dart';
import 'package:oi_coach/features/progresso/view/progresso_view.dart';
import 'package:oi_coach/features/relatorio/view/relatorio_view.dart';
import 'package:oi_coach/features/rotina/view/rotina_view.dart';
import 'package:oi_coach/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
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
          builder: (_, _) => const ConfiguracoesView(),
        ),
      ],
    ),
  ],
);
