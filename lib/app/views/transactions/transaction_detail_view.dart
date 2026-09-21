import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/transactions/transaction_detail_controller.dart';
import '../../helpers/date_helper.dart';
import '../../models/transactions/transaction_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/state_views.dart';
import '../shell/cocoper_shell.dart';

class TransactionDetailView extends GetView<TransactionDetailController> {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 0,
        body: Obx(() {
          if (controller.isLoading.value && controller.record.value == null) {
            return const LoadingCards(count: 4);
          }
          final error = controller.error.value;
          if (error != null && controller.record.value == null) {
            return ErrorState(error: error, onRetry: controller.load);
          }
          final record = controller.record.value;
          if (record == null) return const EmptyState();
          return SingleChildScrollView(
            child: ResponsiveBody(
              maxWidth: 860,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: () => Get.offNamed<void>(
                          Routes.transactionListFor(controller.type.name),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PageHeader(
                          eyebrow: controller.type.label,
                          title: 'details'.tr,
                          subtitle: record.id,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _HeroCard(record: record),
                  const SizedBox(height: 11),
                  Card(
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'date'.tr,
                          value: DateHelper.full(record.date),
                        ),
                        _DetailRow(
                          label: 'active_branch'.tr,
                          value: controller.branchName,
                        ),
                        _DetailRow(label: 'status'.tr, value: record.status),
                        _DetailRow(
                          label: 'amount'.tr,
                          value: _currency(record.amount),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _share(context, record),
                          icon: const Icon(Icons.share_rounded),
                          label: Text('share'.tr),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Get.toNamed<void>(
                            Routes.transactionNewFor(controller.type.name),
                          ),
                          icon: const Icon(Icons.copy_rounded),
                          label: Text('duplicate'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      );

  Future<void> _share(BuildContext context, TransactionRecord record) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${controller.type.label}\n${record.id}\n${record.party}\n${_currency(record.amount)}',
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ready_to_share'.tr)));
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: CocoperColors.line),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: record.type.tint,
                borderRadius: BorderRadius.circular(22),
              ),
              child:
                  Icon(record.type.icon, size: 34, color: CocoperColors.teal),
            ),
            const SizedBox(height: 14),
            Text(
              record.status.toUpperCase(),
              style: const TextStyle(
                color: CocoperColors.tealSoft,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              record.party,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 7),
            Text(record.summary, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 13),
            Text(
              _currency(record.amount),
              style: const TextStyle(
                color: CocoperColors.teal,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: CocoperColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
}

String _currency(double value) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);
