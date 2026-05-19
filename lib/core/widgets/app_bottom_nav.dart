import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';

enum AppNavTab { dashboard, sync, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.isSyncing = false,
  });

  final AppNavTab activeTab;
  final ValueChanged<AppNavTab> onTabSelected;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final syncActive = activeTab == AppNavTab.sync;

    return Container(
      margin: const EdgeInsets.fromLTRB(48, 0, 48, 24),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.navBarBg,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.pie_chart_outline,
            isActive: activeTab == AppNavTab.dashboard,
            onTap: () => onTabSelected(AppNavTab.dashboard),
          ),
          Material(
            color: syncActive ? AppTheme.primary : Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onTabSelected(AppNavTab.sync),
              child: SizedBox(
                width: 44,
                height: 44,
                child: isSyncing
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.textPrimary,
                        ),
                      )
                    : Icon(
                        Icons.sync,
                        color: AppTheme.textPrimary,
                        size: syncActive ? 26 : 28,
                      ),
              ),
            ),
          ),
          _NavIcon(
            icon: Icons.person_outline,
            isActive: activeTab == AppNavTab.profile,
            onTap: () => onTabSelected(AppNavTab.profile),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppTheme.primary : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
