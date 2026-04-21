import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    _Tab('/', Icons.home_outlined, 'Hoje'),
    _Tab('/rotina', Icons.calendar_today_outlined, 'Rotina'),
    _Tab('/progresso', Icons.trending_up, 'Progresso'),
    _Tab('/configuracoes', Icons.settings_outlined, 'Config'),
  ];

  int _currentIndex(String location) {
    for (var i = _tabs.length - 1; i >= 0; i--) {
      if (_tabs[i].path == '/' && location == '/') return i;
      if (_tabs[i].path != '/' && location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
          color: AppColors.background,
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = i == idx;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(tab.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 20,
                          color: active
                              ? AppColors.volt
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.monoLabel(
                            color: active
                                ? AppColors.volt
                                : AppColors.mutedForeground,
                          ).copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String path;
  final IconData icon;
  final String label;
  const _Tab(this.path, this.icon, this.label);
}
