import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_body.dart';
import '../shell/cocoper_shell.dart';

class HomeView extends GetView<ShellController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 0,
        body: SingleChildScrollView(
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    'Good morning, ${controller.session.value.userName}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Everything important for your branch, in one place.',
                  style: TextStyle(color: CocoperColors.muted),
                ),
                const SizedBox(height: 20),
                _DashboardHero(
                    onOpenOperations: () =>
                        Get.toNamed<void>(Routes.transactions)),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) => GridView.count(
                    crossAxisCount: constraints.maxWidth >= 700 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: constraints.maxWidth >= 700 ? 1.35 : 1.45,
                    children: const [
                      _MetricCard(
                          label: 'Purchased',
                          value: '2.5 t',
                          icon: Icons.south_west_rounded,
                          color: CocoperColors.mint),
                      _MetricCard(
                          label: 'Sales',
                          value: '₹81K',
                          icon: Icons.north_east_rounded,
                          color: CocoperColors.sand),
                      _MetricCard(
                          label: 'Received',
                          value: '₹52K',
                          icon: Icons.currency_rupee_rounded,
                          color: Color(0xFFDFF4F1)),
                      _MetricCard(
                          label: 'Workers',
                          value: '18',
                          icon: Icons.groups_rounded,
                          color: CocoperColors.violet),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Fast transactions',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                _QuickAction(
                  title: 'Open operations',
                  subtitle: 'Create and review branch transactions',
                  icon: Icons.grid_view_rounded,
                  color: CocoperColors.mint,
                  onTap: () => Get.toNamed<void>(Routes.transactions),
                ),
                const SizedBox(height: 10),
                _QuickAction(
                  title: 'View statements',
                  subtitle: 'Open registers, balances and reports',
                  icon: Icons.pie_chart_rounded,
                  color: CocoperColors.sand,
                  onTap: () => Get.toNamed<void>(Routes.statements),
                ),
              ],
            ),
          ),
        ),
      );
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.onOpenOperations});

  final VoidCallback onOpenOperations;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: CocoperColors.teal,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COCOS INDIA PVT. LTD.',
                      style: TextStyle(
                          color: CocoperColors.lime,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                  SizedBox(height: 10),
                  Text('Every account operation.\nOne simple app.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.05)),
                  SizedBox(height: 10),
                  Text(
                      'Buy, sell, dispatch, collect and track with clear guided steps.',
                      style: TextStyle(
                          color: Color(0xFFDFF2E7),
                          fontSize: 12,
                          height: 1.35)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onOpenOperations,
              style: FilledButton.styleFrom(
                  backgroundColor: CocoperColors.lime,
                  foregroundColor: CocoperColors.teal),
              child: const Text('Start work'),
            ),
          ],
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: Icon(icon, size: 16, color: CocoperColors.teal)),
              Text(label,
                  style: const TextStyle(
                      color: CocoperColors.muted, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: CocoperColors.teal)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_rounded),
        ),
      );
}
