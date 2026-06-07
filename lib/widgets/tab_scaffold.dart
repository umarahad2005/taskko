import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// The four main tabs of the authenticated app (SRS FR-4.8).
enum TaskkoTab {
  home('Home', '/home', Icons.home_rounded),
  plan('Plan', '/plan', Icons.adjust_rounded),
  hub('Hub', '/hub', Icons.emoji_events_rounded),
  tako('Tako', '/chat', Icons.auto_awesome_rounded);

  const TaskkoTab(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;
}

/// Shared scaffold for the 4 tab screens — gradient background + bottom nav.
class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key, required this.currentTab, required this.body});

  final TaskkoTab currentTab;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(bottom: false, child: body),
      ),
      bottomNavigationBar: _TaskkoNavBar(currentTab: currentTab),
    );
  }
}

class _TaskkoNavBar extends StatelessWidget {
  const _TaskkoNavBar({required this.currentTab});

  final TaskkoTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgRadius,
        boxShadow: const [
          BoxShadow(color: Color(0x1A143C5A), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final tab in TaskkoTab.values)
              _NavItem(
                tab: tab,
                selected: tab == currentTab,
                onTap: () {
                  if (tab != currentTab) context.go(tab.route);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final TaskkoTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.ink4;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(tab.label, style: AppTypography.ui(11, color: color, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
