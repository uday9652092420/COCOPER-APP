import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/reports/report_detail_controller.dart';
import '../../models/reports/report_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/state_views.dart';
import '../shell/cocoper_shell.dart';

class ReportDetailView extends GetView<ReportDetailController> {
  const ReportDetailView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 2,
        body: SingleChildScrollView(
          child: ResponsiveBody(
            maxWidth: 1050,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.outlined(
                      onPressed: () => Get.offAllNamed<void>(Routes.reports),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PageHeader(
                        eyebrow: 'reports'.tr,
                        title: controller.type.label,
                        subtitle:
                            '${controller.branchName} · ${'this_month'.tr}',
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: controller.type.tint,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child:
                          Icon(controller.type.icon, color: CocoperColors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Obx(
                  () => _RangeSelector(
                    value: controller.range.value,
                    onChanged: controller.setRange,
                  ),
                ),
                const SizedBox(height: 13),
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.report.value == null) {
                    return const LoadingCards(count: 5);
                  }
                  final error = controller.error.value;
                  if (error != null && controller.report.value == null) {
                    return SizedBox(
                      height: 420,
                      child: ErrorState(error: error, onRetry: controller.load),
                    );
                  }
                  final data = controller.report.value;
                  if (data == null) return const SizedBox.shrink();
                  return _ReportContent(data: data, controller: controller);
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.value, required this.onChanged});

  final ReportRange value;
  final Future<void> Function(ReportRange) onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<ReportRange>(
          segments: [
            ButtonSegment(
              value: ReportRange.last30Days,
              label: Text('this_month'.tr),
            ),
            ButtonSegment(
              value: ReportRange.last90Days,
              label: Text('last_90_days'.tr),
            ),
            ButtonSegment(
                value: ReportRange.allTime, label: Text('all_time'.tr)),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      );
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({required this.data, required this.controller});

  final ReportData data;
  final ReportDetailController controller;

  @override
  Widget build(BuildContext context) {
    if (data.type == ReportType.profitLoss) {
      return _ProfitLoss(data: data, controller: controller);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.parties.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'select_account'.tr,
                    style: const TextStyle(
                      color: CocoperColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(
                      () => Row(
                        children: data.parties
                            .map(
                              (party) => Padding(
                                padding: const EdgeInsets.only(right: 7),
                                child: ChoiceChip(
                                  label: Text(party),
                                  selected: (controller.selectedParty.value ??
                                          data.parties.first) ==
                                      party,
                                  onSelected: (_) => controller.setParty(party),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 11),
        ],
        _SummaryCard(data: data),
        const SizedBox(height: 13),
        if (data.rows.isEmpty)
          const SizedBox(height: 350, child: EmptyState())
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  childAspectRatio: columns == 2 ? 3.3 : 3.15,
                ),
                itemCount: data.rows.length,
                itemBuilder: (_, index) =>
                    _ReportRowCard(row: data.rows[index]),
              );
            },
          ),
        const SizedBox(height: 13),
        _ReportActions(data: data, controller: controller),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: data.type.tint,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: CocoperColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: CocoperColors.teal,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(data.type.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'report_summary'.tr,
                    style: const TextStyle(
                      color: CocoperColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.summary,
                    style: const TextStyle(
                      color: CocoperColors.ink,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (data.subtitle.isNotEmpty)
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        color: CocoperColors.muted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.north_east_rounded, color: CocoperColors.teal),
          ],
        ),
      );
}

class _ReportRowCard extends StatelessWidget {
  const _ReportRowCard({required this.row});

  final ReportRow row;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF6E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: CocoperColors.teal,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      row.primary,
                      style: const TextStyle(
                        color: CocoperColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      row.secondary,
                      style: const TextStyle(
                        color: CocoperColors.tealSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      row.tertiary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                row.value,
                style: TextStyle(
                  color: row.credit ? CocoperColors.coral : CocoperColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProfitLoss extends StatelessWidget {
  const _ProfitLoss({required this.data, required this.controller});

  final ReportData data;
  final ReportDetailController controller;

  @override
  Widget build(BuildContext context) {
    final subtitle = data.subtitle.endsWith(' net margin')
        ? '${data.subtitle.replaceFirst(' net margin', '')} ${'net_margin'.tr}'
        : data.subtitle;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CocoperColors.teal, Color(0xFF0B725F)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26083F3A),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'net_profit'.tr.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFC7DED5),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.summary,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: CocoperColors.lime,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: CocoperColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...data.metrics.entries.map((entry) {
          final negative = entry.key.contains('Purchases') ||
              entry.key.toLowerCase().contains('expenses');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: negative
                      ? const Color(0xFFFAE7DD)
                      : const Color(0xFFE6F3E5),
                  foregroundColor:
                      negative ? CocoperColors.coral : Colors.green.shade700,
                  child: Icon(
                    negative
                        ? Icons.south_east_rounded
                        : Icons.north_east_rounded,
                  ),
                ),
                title: Text(_metricLabel(entry.key)),
                trailing: Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 5),
        _ReportActions(data: data, controller: controller),
      ],
    );
  }
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.data, required this.controller});

  final ReportData data;
  final ReportDetailController controller;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.load(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('refresh'.tr),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => OutlinedButton.icon(
                onPressed: controller.isExporting.value
                    ? null
                    : () => _export(context),
                icon: const Icon(Icons.download_rounded),
                label: Text('export'.tr),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _share(context),
              icon: const Icon(Icons.share_rounded),
              label: Text('share'.tr),
            ),
          ),
        ],
      );

  Future<void> _export(BuildContext context) async {
    final url = await controller.export();
    if (url == null || url.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('report_copied'.tr)));
    }
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: '${data.type.label}: ${data.summary}'),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ready_to_share'.tr)));
    }
  }
}

String _metricLabel(String value) => switch (value) {
      'Total sales' => 'metric_total_sales'.tr,
      'Purchases / COGS' => 'metric_purchases_cogs'.tr,
      'Gross profit' => 'metric_gross_profit'.tr,
      'Operating expenses' => 'metric_operating_expenses'.tr,
      'Other income' => 'metric_other_income'.tr,
      _ => value,
    };
