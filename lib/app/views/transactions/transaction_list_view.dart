import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';
import '../../controllers/transactions/transaction_list_controller.dart';
import '../../helpers/date_helper.dart';
import '../../models/transactions/transaction_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/state_views.dart';
import '../shell/cocoper_shell.dart';

class TransactionListView extends GetView<TransactionListController> {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 1,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => controller.load(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ResponsiveBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton.outlined(
                                onPressed: () =>
                                    Get.offAllNamed<void>(Routes.transactions),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: PageHeader(
                                  eyebrow: 'transactions'.tr,
                                  title: controller.type.label,
                                  subtitle:
                                      '${controller.branchName} · ${'recent_entries'.tr}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _Metrics(),
                          const SizedBox(height: 14),
                          TextField(
                            onChanged: controller.setSearch,
                            decoration: InputDecoration(
                              hintText: 'search'.tr,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(
                                tooltip: 'filter'.tr,
                                onPressed: () {},
                                icon: const Icon(Icons.tune_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'recent_entries'.tr,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.records.isEmpty) {
                      return const SliverToBoxAdapter(child: LoadingCards());
                    }
                    final error = controller.error.value;
                    if (error != null && controller.records.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child:
                            ErrorState(error: error, onRetry: controller.load),
                      );
                    }
                    if (controller.records.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(onAction: _create),
                      );
                    }
                    return SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final tablet = constraints.crossAxisExtent >=
                            AppConstants.mobileBreakpoint;
                        return SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            tablet ? 28 : 16,
                            12,
                            tablet ? 28 : 16,
                            104,
                          ),
                          sliver: SliverGrid.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: tablet ? 2 : 1,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: tablet ? 3.45 : 3.0,
                            ),
                            itemCount: controller.records.length,
                            itemBuilder: (_, index) {
                              final record = controller.records[index];
                              return _RecordCard(
                                record: record,
                                onTap: () => Get.toNamed<void>(
                                  Routes.transactionDetailFor(
                                    controller.type.name,
                                    record.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            Positioned(
              left: MediaQuery.sizeOf(context).width < 500 ? 16 : null,
              right: 16,
              bottom: 16,
              width: MediaQuery.sizeOf(context).width >= 500 ? 280 : null,
              child: FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add_rounded),
                label: Text('create_entry'.tr),
              ),
            ),
          ],
        ),
      );

  void _create() => Get.toNamed<void>(
        Routes.transactionNewFor(controller.type.name),
      );
}

class _Metrics extends StatelessWidget {
  const _Metrics();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _MetricCard(
              label: 'today'.tr,
              value: '3',
              caption: 'entries'.tr,
              dark: true,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _MetricCard(
              label: 'total_value'.tr,
              value: '₹1.19L',
              caption: 'this_branch'.tr,
            ),
          ),
        ],
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
    this.dark = false,
  });

  final String label;
  final String value;
  final String caption;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        height: 102,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? CocoperColors.teal : const Color(0xFFF7E9BD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: dark ? Colors.white70 : CocoperColors.muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: dark ? Colors.white : CocoperColors.ink,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              caption,
              style: TextStyle(
                color: dark ? Colors.white70 : CocoperColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onTap});

  final TransactionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: record.type.tint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(record.type.icon, color: CocoperColors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              record.id,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CocoperColors.tealSoft,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          _StatusPill(record: record),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.party,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${DateHelper.short(record.date)} · ${record.summary}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CocoperColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                        decimalDigits: 0,
                      ).format(record.amount),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: CocoperColors.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context) {
    final pending =
        record.syncPending || record.status.toLowerCase().contains('pending');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pending ? const Color(0xFFF9E2D8) : const Color(0xFFE2F3E7),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        record.status.toUpperCase(),
        style: TextStyle(
          color: pending ? const Color(0xFF9C4B2D) : const Color(0xFF1C6A45),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
