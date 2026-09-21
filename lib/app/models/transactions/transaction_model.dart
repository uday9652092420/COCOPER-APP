import '../session/user_session_model.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TransactionType {
  purchaseOrder,
  purchaseInvoice,
  sales,
  loadingDispatch,
  customerReceipt,
  supplierPayment,
  cashBankExpense,
  labourPayment,
  bagPurchase,
}

extension TransactionTypeX on TransactionType {
  String get apiValue => switch (this) {
        TransactionType.purchaseOrder => 'purchase-orders',
        TransactionType.purchaseInvoice => 'purchase-invoices',
        TransactionType.sales => 'sales',
        TransactionType.loadingDispatch => 'dispatches',
        TransactionType.customerReceipt => 'customer-receipts',
        TransactionType.supplierPayment => 'supplier-payments',
        TransactionType.cashBankExpense => 'cash-bank-expenses',
        TransactionType.labourPayment => 'labour-payments',
        TransactionType.bagPurchase => 'bag-purchases',
      };

  IconData get icon => switch (this) {
        TransactionType.purchaseOrder => Icons.edit_note_rounded,
        TransactionType.purchaseInvoice => Icons.receipt_long_rounded,
        TransactionType.sales => Icons.spa_rounded,
        TransactionType.loadingDispatch => Icons.local_shipping_rounded,
        TransactionType.customerReceipt => Icons.payments_rounded,
        TransactionType.supplierPayment => Icons.handshake_rounded,
        TransactionType.cashBankExpense => Icons.account_balance_wallet_rounded,
        TransactionType.labourPayment => Icons.engineering_rounded,
        TransactionType.bagPurchase => Icons.inventory_2_rounded,
      };

  Color get tint => switch (this) {
        TransactionType.purchaseOrder => const Color(0xFFE9F6D8),
        TransactionType.purchaseInvoice => const Color(0xFFF8EAD2),
        TransactionType.sales => const Color(0xFFDFF2E7),
        TransactionType.loadingDispatch => const Color(0xFFF8E6D0),
        TransactionType.customerReceipt => const Color(0xFFD9F1ED),
        TransactionType.supplierPayment => const Color(0xFFF7E6B9),
        TransactionType.cashBankExpense => const Color(0xFFEDE6F7),
        TransactionType.labourPayment => const Color(0xFFF6E2E6),
        TransactionType.bagPurchase => const Color(0xFFE0EFF4),
      };

  String get translationKey => 'transaction_$name';

  String get label => translationKey.tr;
}

enum FieldKey {
  branch,
  supplier,
  customer,
  warehouse,
  invoiceNumber,
  orderNumber,
  invoiceAllocation,
  invoice,
  item,
  quantityMode,
  quantity,
  discount,
  actualQuantity,
  purchaseRate,
  salesRate,
  loadingCharge,
  marketCess,
  bagStickCharge,
  freight,
  paymentMode,
  amount,
  vehicleNumber,
  driverName,
  driverMobile,
  bagType,
  fillingWeight,
  workerType,
  labour,
  temporaryWorkerName,
  morningOt,
  eveningOt,
  otRate,
  transactionKind,
  expenseHead,
  description,
}

enum FieldKind { text, decimal, money, choice, phone, readOnly }

String transactionOptionLabel(String value) {
  final key =
      'option_${value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '')}';
  final translated = key.tr;
  return translated == key ? value : translated;
}

class TransactionField extends Equatable {
  const TransactionField({
    required this.key,
    required this.label,
    required this.kind,
    this.required = true,
    this.options = const [],
    this.lookupKey,
    this.hint,
  });

  final FieldKey key;
  final String label;
  final FieldKind kind;
  final bool required;
  final List<String> options;
  final String? lookupKey;
  final String? hint;

  @override
  List<Object?> get props => [
        key,
        label,
        kind,
        required,
        options,
        lookupKey,
        hint,
      ];
}

class TransactionStep extends Equatable {
  const TransactionStep({
    required this.title,
    required this.help,
    this.fields = const [],
    this.isReview = false,
  });

  final String title;
  final String help;
  final List<TransactionField> fields;
  final bool isReview;

  @override
  List<Object?> get props => [title, help, fields, isReview];
}

class TransactionDefinition extends Equatable {
  const TransactionDefinition({required this.type, required this.steps});

  final TransactionType type;
  final List<TransactionStep> steps;

  @override
  List<Object?> get props => [type, steps];
}

class TransactionRecord extends Equatable {
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.party,
    required this.date,
    required this.status,
    required this.amount,
    required this.summary,
    required this.branchId,
    this.syncPending = false,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        id: json['id'] as String,
        type: TransactionType.values.byName(json['type'] as String),
        party: json['party'] as String,
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String,
        amount: (json['amount'] as num).toDouble(),
        summary: json['summary'] as String,
        branchId: json['branchId'] as String,
        syncPending: json['syncPending'] as bool? ?? false,
      );

  final String id;
  final TransactionType type;
  final String party;
  final DateTime date;
  final String status;
  final double amount;
  final String summary;
  final String branchId;
  final bool syncPending;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'party': party,
        'date': date.toIso8601String(),
        'status': status,
        'amount': amount,
        'summary': summary,
        'branchId': branchId,
        'syncPending': syncPending,
      };

  @override
  List<Object?> get props => [
        id,
        type,
        party,
        date,
        status,
        amount,
        summary,
        branchId,
        syncPending,
      ];
}

class TransactionDraft extends Equatable {
  const TransactionDraft({
    required this.type,
    required this.values,
    required this.step,
    required this.updatedAt,
  });

  factory TransactionDraft.fromJson(Map<String, dynamic> json) =>
      TransactionDraft(
        type: TransactionType.values.byName(json['type'] as String),
        values: (json['values'] as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry('$key', '$value'),
        ),
        step: (json['step'] as num).toInt(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final TransactionType type;
  final Map<String, String> values;
  final int step;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'values': values,
        'step': step,
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [type, values, step, updatedAt];
}

class TransactionCreateRequest {
  const TransactionCreateRequest({
    required this.type,
    required this.branchId,
    required this.values,
    required this.clientCreatedAt,
  });

  final TransactionType type;
  final String branchId;
  final Map<String, String> values;
  final DateTime clientCreatedAt;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'branchId': branchId,
        'values': values,
        'clientCreatedAt': clientCreatedAt.toUtc().toIso8601String(),
      };
}

class PaginatedTransactions {
  const PaginatedTransactions({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PaginatedTransactions.fromJson(Map<String, dynamic> json) =>
      PaginatedTransactions(
        items: (json['items'] as List<dynamic>? ?? const [])
            .map(
              (item) => TransactionRecord.fromJson(
                (item as Map<dynamic, dynamic>).map(
                  (key, value) => MapEntry('$key', value),
                ),
              ),
            )
            .toList(growable: false),
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['pageSize'] as num?)?.toInt() ?? 30,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );

  final List<TransactionRecord> items;
  final int page;
  final int pageSize;
  final int total;
}

abstract final class TransactionAccess {
  static List<TransactionType> forRole(UserRole role) => switch (role) {
        UserRole.financeManager => const [
            TransactionType.purchaseOrder,
            TransactionType.purchaseInvoice,
            TransactionType.sales,
            TransactionType.loadingDispatch,
            TransactionType.customerReceipt,
            TransactionType.supplierPayment,
            TransactionType.cashBankExpense,
            TransactionType.labourPayment,
          ],
        UserRole.warehouseManager => const [
            TransactionType.loadingDispatch,
            TransactionType.labourPayment,
          ],
        UserRole.procurementManager => const [
            TransactionType.purchaseOrder,
            TransactionType.purchaseInvoice,
            TransactionType.bagPurchase,
            TransactionType.supplierPayment,
          ],
        UserRole.salesManager => const [
            TransactionType.sales,
            TransactionType.customerReceipt,
          ],
      };
}

abstract final class TransactionCalculator {
  static bool isPieceMode(String mode) => mode.toLowerCase().contains('piece');

  static double maxDiscount(String mode) => isPieceMode(mode) ? 100 : 50;

  static double notificationThreshold(String mode) =>
      isPieceMode(mode) ? 20 : 30;

  static double actualQuantity(Map<String, String> values) {
    final quantity = double.tryParse(values[FieldKey.quantity.name] ?? '') ?? 0;
    final discount = double.tryParse(values[FieldKey.discount.name] ?? '') ?? 0;
    final mode = values[FieldKey.quantityMode.name] ?? '';
    final discountBase = isPieceMode(mode) ? 1000 : 100;
    final totalDiscount = quantity / discountBase * discount;
    return (quantity - totalDiscount).clamp(0, double.infinity).toDouble();
  }

  static double total(TransactionType type, Map<String, String> values) {
    double number(FieldKey key) => double.tryParse(values[key.name] ?? '') ?? 0;

    if (type == TransactionType.customerReceipt ||
        type == TransactionType.supplierPayment ||
        type == TransactionType.cashBankExpense) {
      return number(FieldKey.amount);
    }
    if (type == TransactionType.labourPayment) {
      return (number(FieldKey.morningOt) + number(FieldKey.eveningOt)) *
              number(FieldKey.otRate) +
          number(FieldKey.loadingCharge);
    }
    final quantity = values.containsKey(FieldKey.actualQuantity.name)
        ? actualQuantity(values)
        : number(FieldKey.quantity);
    final rate = type == TransactionType.sales
        ? number(FieldKey.salesRate)
        : type == TransactionType.bagPurchase
            ? number(FieldKey.purchaseRate)
            : number(FieldKey.purchaseRate);
    return quantity * rate +
        number(FieldKey.loadingCharge) +
        number(FieldKey.marketCess) +
        number(FieldKey.bagStickCharge) +
        number(FieldKey.freight);
  }
}
