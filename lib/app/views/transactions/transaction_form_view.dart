import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';
import '../../controllers/transactions/transaction_form_controller.dart';
import '../../models/transactions/transaction_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../shell/cocoper_shell.dart';

class TransactionFormView extends GetView<TransactionFormController> {
  const TransactionFormView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 1,
        body: Obx(() {
          final definition = controller.definition;
          final activeStep = controller.activeStep;
          final tablet =
              MediaQuery.sizeOf(context).width >= AppConstants.mobileBreakpoint;
          final content =
              _StepContent(step: activeStep, controller: controller);
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ResponsiveBody(
                    maxWidth: 1120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: controller.currentStep.value > 0
                                  ? controller.previous
                                  : () => Get.offNamed<void>(
                                        Routes.transactionListFor(
                                          controller.type.name,
                                        ),
                                      ),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PageHeader(
                                eyebrow: controller.type.label,
                                title: 'new_entry'.tr,
                                subtitle:
                                    '${controller.branchName} · ${'step'.tr} ${controller.currentStep.value + 1} ${'of'.tr} ${definition.steps.length}',
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: controller.type.tint,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                controller.type.icon,
                                color: CocoperColors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        _ProgressIndicator(
                          current: controller.currentStep.value,
                          count: definition.steps.length,
                        ),
                        if (controller.errorMessage.value.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _InlineError(
                            message: _localizedMessage(
                              controller.errorMessage.value,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (tablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: content),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 2,
                                child: _ReviewCard(controller: controller),
                              ),
                            ],
                          )
                        else
                          content,
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomActionBar(
                submitting: controller.isSubmitting.value,
                isLastStep: controller.isLastStep,
                onSaveDraft: () async {
                  await controller.saveDraft();
                  Get.snackbar('save_draft'.tr, 'saved_offline_detail'.tr);
                },
                onPrimary: () => _advance(context),
              ),
            ],
          );
        }),
      );

  Future<void> _advance(BuildContext context) async {
    if (!controller.isLastStep) {
      controller.next();
      return;
    }
    final record = await controller.submit();
    if (!context.mounted || record == null) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFFE2F3E7),
          child: Icon(
            record.syncPending
                ? Icons.cloud_upload_rounded
                : Icons.check_rounded,
            color: CocoperColors.teal,
            size: 30,
          ),
        ),
        title: Text('transaction_saved'.tr),
        content: Text(
          record.syncPending
              ? 'saved_offline_detail'.tr
              : 'saved_synced_detail'.tr,
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Get.offAllNamed<void>(
                Routes.transactionListFor(controller.type.name),
              );
            },
            child: Text('view_entries'.tr),
          ),
        ],
      ),
    );
  }

  static String _localizedMessage(String message) {
    final translated = message.tr;
    return translated == message ? 'something_went_wrong'.tr : translated;
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.current, required this.count});

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          count,
          (index) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 6,
              margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: index <= current
                    ? CocoperColors.tealSoft
                    : CocoperColors.line,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      );
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.controller});

  final TransactionStep step;
  final TransactionFormController controller;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(step.help, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (step.isReview)
            _ReviewCard(controller: controller)
          else
            ...step.fields
                .where((field) => controller.isFieldVisible(field.key))
                .map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _FieldCard(
                      field: field,
                      value: controller.values[field.key.name] ?? '',
                      options: field.lookupKey == null
                          ? field.options
                          : controller.lookups[field.lookupKey] ?? const [],
                      loadingOptions: field.lookupKey != null &&
                          controller.isLoadingLookups.value,
                      errorKey: controller.fieldErrors[field.key.name],
                      onChanged: (value) =>
                          controller.updateField(field.key, value),
                    ),
                  ),
                ),
          if ((controller.type == TransactionType.purchaseInvoice ||
                  controller.type == TransactionType.sales) &&
              controller.currentStep.value == 1)
            _DiscountSafety(values: controller.values),
          if (controller.type == TransactionType.labourPayment &&
              controller.currentStep.value == 1)
            _AutoTotal(total: controller.total),
        ],
      );
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.field,
    required this.value,
    required this.options,
    required this.loadingOptions,
    required this.onChanged,
    this.errorKey,
  });

  final TransactionField field;
  final String value;
  final List<String> options;
  final bool loadingOptions;
  final ValueChanged<String> onChanged;
  final String? errorKey;

  @override
  Widget build(BuildContext context) {
    final error = errorKey?.tr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F2E5),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    _fieldIcon(field.key),
                    size: 16,
                    color: CocoperColors.tealSoft,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    field.label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                if (!field.required)
                  Text(
                    'optional'.tr,
                    style: const TextStyle(
                      color: CocoperColors.muted,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 11),
            if (field.kind == FieldKind.choice)
              if (loadingOptions && options.isEmpty)
                const LinearProgressIndicator()
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options
                      .map(
                        (option) => ChoiceChip(
                          label: Text(transactionOptionLabel(option)),
                          selected: value == option,
                          onSelected: (_) => onChanged(option),
                          showCheckmark: true,
                        ),
                      )
                      .toList(growable: false),
                )
            else if (field.kind == FieldKind.readOnly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  value.isEmpty ? '0' : value,
                  style: const TextStyle(
                    color: CocoperColors.teal,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              TextFormField(
                initialValue: value,
                onChanged: onChanged,
                keyboardType: switch (field.kind) {
                  FieldKind.decimal ||
                  FieldKind.money =>
                    const TextInputType.numberWithOptions(decimal: true),
                  FieldKind.phone => TextInputType.phone,
                  _ => TextInputType.text,
                },
                inputFormatters: switch (field.kind) {
                  FieldKind.decimal || FieldKind.money => [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  FieldKind.phone => [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  _ => null,
                },
                decoration: InputDecoration(
                  errorText: error,
                  prefixText: field.kind == FieldKind.money ? '₹ ' : null,
                  hintText: field.label,
                ),
              ),
            if (error != null && field.kind == FieldKind.choice) ...[
              const SizedBox(height: 6),
              Text(
                error,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _fieldIcon(FieldKey key) => switch (key) {
        FieldKey.branch || FieldKey.warehouse => Icons.warehouse_rounded,
        FieldKey.supplier => Icons.storefront_rounded,
        FieldKey.customer => Icons.person_rounded,
        FieldKey.item => Icons.spa_rounded,
        FieldKey.quantity ||
        FieldKey.discount ||
        FieldKey.actualQuantity =>
          Icons.scale_rounded,
        FieldKey.purchaseRate ||
        FieldKey.salesRate ||
        FieldKey.amount ||
        FieldKey.otRate =>
          Icons.currency_rupee_rounded,
        FieldKey.vehicleNumber ||
        FieldKey.driverName ||
        FieldKey.driverMobile =>
          Icons.local_shipping_rounded,
        FieldKey.labour ||
        FieldKey.temporaryWorkerName ||
        FieldKey.workerType =>
          Icons.engineering_rounded,
        FieldKey.paymentMode => Icons.account_balance_wallet_rounded,
        FieldKey.expenseHead ||
        FieldKey.transactionKind =>
          Icons.receipt_long_rounded,
        _ => Icons.edit_rounded,
      };
}

class _DiscountSafety extends StatelessWidget {
  const _DiscountSafety({required this.values});

  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    final mode = values[FieldKey.quantityMode.name] ?? '';
    final discount = double.tryParse(values[FieldKey.discount.name] ?? '') ?? 0;
    final threshold = TransactionCalculator.notificationThreshold(mode);
    final warning = discount > threshold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF0E7) : const Color(0xFFEEF8EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: warning ? const Color(0xFFEDB79D) : const Color(0xFFCFE2D1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                warning ? CocoperColors.coral : Colors.green.shade600,
            foregroundColor: Colors.white,
            child: Icon(
              warning ? Icons.priority_high_rounded : Icons.check_rounded,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning ? 'approval_required'.tr : 'discount_safe'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${TransactionCalculator.isPieceMode(mode) ? 'per_thousand_pieces'.tr : 'per_hundred_kg'.tr} · ${'notify_above'.tr} ${threshold.toInt()} · ${'maximum'.tr} ${TransactionCalculator.maxDiscount(mode).toInt()}',
                  style: const TextStyle(
                    color: CocoperColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoTotal extends StatelessWidget {
  const _AutoTotal({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 11),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6E6B7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'calculated_labour_payment'.tr,
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              _currency(total),
              style: const TextStyle(
                color: Color(0xFF654817),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.controller});

  final TransactionFormController controller;

  @override
  Widget build(BuildContext context) {
    final entries = controller.values.entries
        .where((entry) => entry.value.trim().isNotEmpty && entry.value != '0')
        .take(10)
        .toList(growable: false);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: controller.type.tint,
            child: Row(
              children: [
                Icon(controller.type.icon, color: CocoperColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.type.label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'review_empty'.tr,
                style: const TextStyle(color: CocoperColors.muted),
              ),
            )
          else
            ...entries.map(
              (entry) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: CocoperColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _labelFor(entry.key),
                        style: const TextStyle(
                          color: CocoperColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        transactionOptionLabel(entry.value),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFEDF7E8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'estimated_total'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  _currency(controller.total),
                  style: const TextStyle(
                    color: CocoperColors.teal,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(String key) {
    for (final step in controller.definition.steps) {
      for (final field in step.fields) {
        if (field.key.name == key) return field.label;
      }
    }
    return key;
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECE4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDB79D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: CocoperColors.coral),
            const SizedBox(width: 9),
            Expanded(child: Text(message)),
          ],
        ),
      );
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.submitting,
    required this.isLastStep,
    required this.onSaveDraft,
    required this.onPrimary,
  });

  final bool submitting;
  final bool isLastStep;
  final Future<void> Function() onSaveDraft;
  final Future<void> Function() onPrimary;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 10,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Row(
                  children: [
                    if (MediaQuery.sizeOf(context).width >= 500) ...[
                      OutlinedButton.icon(
                        onPressed: submitting ? null : onSaveDraft,
                        icon: const Icon(Icons.cloud_done_rounded),
                        label: Text('save_draft'.tr),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: submitting ? null : onPrimary,
                        icon: submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isLastStep
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                        label: Text(isLastStep ? 'save'.tr : 'next'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

String _currency(double value) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);
