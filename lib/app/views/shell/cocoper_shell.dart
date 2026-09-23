import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/constants.dart';
import '../../controllers/shell/shell_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/sync_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class CocoperShell extends GetView<ShellController> {
  const CocoperShell({
    required this.body,
    required this.activeIndex,
    super.key,
  });

  final Widget body;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final tablet = width >= AppConstants.mobileBreakpoint;
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: const Icon(Icons.grid_view_outlined),
        selectedIcon: const Icon(Icons.grid_view_rounded),
        label: 'Operations',
      ),
      NavigationDestination(
        icon: const Icon(Icons.pie_chart_outline_rounded),
        selectedIcon: const Icon(Icons.pie_chart_rounded),
        label: 'Statements',
      ),
      NavigationDestination(
        icon: const Icon(Icons.more_horiz_rounded),
        selectedIcon: const Icon(Icons.more_horiz_rounded),
        label: 'More',
      ),
    ];

    if (!tablet) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _AppHeader(tablet: false),
              Expanded(child: body),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: activeIndex,
          onDestinationSelected: _navigate,
          destinations: destinations,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _AppHeader(tablet: true),
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: activeIndex,
                    extended: width >= AppConstants.wideTabletBreakpoint,
                    onDestinationSelected: _navigate,
                    destinations: destinations
                        .map(
                          (item) => NavigationRailDestination(
                            icon: item.icon,
                            selectedIcon: item.selectedIcon,
                            label: Text(item.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(int index) {
    if (index == activeIndex) return;
    final route = switch (index) {
      0 => Routes.home,
      1 => Routes.transactions,
      2 => Routes.statements,
      _ => Routes.more,
    };
    Get.offAllNamed<void>(route);
  }
}

class _AppHeader extends GetView<ShellController> {
  const _AppHeader({required this.tablet});

  final bool tablet;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: Container(
          padding:
              EdgeInsets.fromLTRB(tablet ? 24 : 14, 11, tablet ? 24 : 14, 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: CocoperColors.line)),
          ),
          child: Obx(() {
            final session = controller.session.value;
            return Column(
              children: [
                Row(
                  children: [
                    if (tablet)
                      const CocoperLogo(size: 46)
                    else
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: const CocoperLogo(size: 38),
                        ),
                      ),
                    const Spacer(),
                    if (tablet) ...[
                      _SyncChip(count: SyncService.pendingCount.value),
                      const SizedBox(width: 8),
                      _BranchSelector(controller: controller, compact: true),
                      const SizedBox(width: 8),
                      _ContextChip(
                        icon: Icons.business_rounded,
                        label: session.organizationName,
                      ),
                      const SizedBox(width: 8),
                    ],
                    PopupMenuButton<String>(
                      tooltip: 'language'.tr,
                      onSelected: controller.changeLanguage,
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'en', child: Text('English')),
                        PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
                        PopupMenuItem(value: 'te', child: Text('తెలుగు')),
                        PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
                        PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
                      ],
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          border: Border.all(color: CocoperColors.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              Get.locale?.languageCode.toUpperCase() ?? 'EN',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Profile',
                      onPressed: () => Get.toNamed<void>(Routes.profile),
                      icon: const Icon(Icons.person_outline_rounded),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 36, height: 36),
                    ),
                  ],
                ),
                if (!tablet) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _BranchSelector(controller: controller),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ContextChip(
                          icon: Icons.business_rounded,
                          label: session.organizationName,
                          fill: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
        ),
      );
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector({required this.controller, this.compact = false});

  final ShellController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) => Obx(
        () => PopupMenuButton<String>(
          tooltip: 'Select active branch',
          onSelected: controller.selectBranch,
          itemBuilder: (_) {
            if (controller.branches.isEmpty) {
              return const [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text('No assigned branches'),
                ),
              ];
            }
            return controller.branches
                .map((branch) => PopupMenuItem<String>(
                      value: branch.id,
                      child: Text(branch.name),
                    ))
                .toList(growable: false);
          },
          child: _ContextChip(
            icon: Icons.warehouse_rounded,
            label: compact
                ? controller.session.value.branchName.isEmpty
                    ? 'No branch selected'
                    : controller.session.value.branchName
                : '${'active_branch'.tr} · ${controller.session.value.branchName.isEmpty ? 'None' : controller.session.value.branchName}',
            fill: !compact,
          ),
        ),
      );
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({
    required this.icon,
    required this.label,
    this.fill = false,
  });

  final IconData icon;
  final String label;
  final bool fill;

  @override
  Widget build(BuildContext context) => Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF7EA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFD9E5DA),
          ),
        ),
        child: Row(
          mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: CocoperColors.teal,
            ),
            const SizedBox(width: 8),
            if (fill)
              Expanded(child: _ContextText(label: label))
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: _ContextText(label: label),
              ),
          ],
        ),
      );
}

class _ContextText extends StatelessWidget {
  const _ContextText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      );
}

class _SyncChip extends StatelessWidget {
  const _SyncChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(
            count == 0 ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
            size: 18,
            color: count == 0 ? Colors.green.shade700 : CocoperColors.coral,
          ),
          const SizedBox(width: 5),
          Text(
            count == 0 ? 'synced'.tr : '$count ${'sync_pending'.tr}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      );
}
