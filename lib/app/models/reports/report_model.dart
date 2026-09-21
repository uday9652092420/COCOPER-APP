import '../session/user_session_model.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ReportType {
  purchaseRegister,
  salesRegister,
  supplierStatement,
  customerStatement,
  labourAttendance,
  pendingDispatch,
  outstanding,
  profitLoss,
}

extension ReportTypeX on ReportType {
  String get apiValue => switch (this) {
        ReportType.purchaseRegister => 'purchase-register',
        ReportType.salesRegister => 'sales-register',
        ReportType.supplierStatement => 'supplier-statement',
        ReportType.customerStatement => 'customer-statement',
        ReportType.labourAttendance => 'labour-attendance',
        ReportType.pendingDispatch => 'pending-dispatch',
        ReportType.outstanding => 'outstanding',
        ReportType.profitLoss => 'profit-loss',
      };

  IconData get icon => switch (this) {
        ReportType.purchaseRegister => Icons.south_east_rounded,
        ReportType.salesRegister => Icons.north_east_rounded,
        ReportType.supplierStatement => Icons.account_balance_rounded,
        ReportType.customerStatement => Icons.receipt_rounded,
        ReportType.labourAttendance => Icons.groups_rounded,
        ReportType.pendingDispatch => Icons.local_shipping_rounded,
        ReportType.outstanding => Icons.currency_rupee_rounded,
        ReportType.profitLoss => Icons.trending_up_rounded,
      };

  Color get tint => switch (this) {
        ReportType.purchaseRegister => const Color(0xFFE9F6D8),
        ReportType.salesRegister => const Color(0xFFDFF2E7),
        ReportType.supplierStatement => const Color(0xFFF7E6B9),
        ReportType.customerStatement => const Color(0xFFD9F1ED),
        ReportType.labourAttendance => const Color(0xFFF6E2E6),
        ReportType.pendingDispatch => const Color(0xFFF8E6D0),
        ReportType.outstanding => const Color(0xFFEDE6F7),
        ReportType.profitLoss => const Color(0xFFDFF2E7),
      };

  String get translationKey => 'report_$name';

  String get label => translationKey.tr;
}

enum ReportRange { last30Days, last90Days, allTime }

class ReportQuery extends Equatable {
  const ReportQuery({
    required this.type,
    required this.branchId,
    this.range = ReportRange.last90Days,
    this.partyId,
  });

  final ReportType type;
  final String branchId;
  final ReportRange range;
  final String? partyId;

  @override
  List<Object?> get props => [type, branchId, range, partyId];
}

class ReportRow extends Equatable {
  const ReportRow({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.value,
    this.credit = false,
  });

  factory ReportRow.fromJson(Map<String, dynamic> json) => ReportRow(
        primary: json['primary'] as String,
        secondary: json['secondary'] as String,
        tertiary: json['tertiary'] as String,
        value: json['value'] as String,
        credit: json['credit'] as bool? ?? false,
      );

  final String primary;
  final String secondary;
  final String tertiary;
  final String value;
  final bool credit;

  Map<String, dynamic> toJson() => {
        'primary': primary,
        'secondary': secondary,
        'tertiary': tertiary,
        'value': value,
        'credit': credit,
      };

  @override
  List<Object?> get props => [primary, secondary, tertiary, value, credit];
}

class ReportData extends Equatable {
  const ReportData({
    required this.type,
    required this.summary,
    required this.rows,
    this.subtitle = '',
    this.metrics = const {},
    this.parties = const [],
  });

  factory ReportData.fromJson(Map<String, dynamic> json) => ReportData(
        type: ReportType.values.byName(json['type'] as String),
        summary: json['summary'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        rows: (json['rows'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(ReportRow.fromJson)
            .toList(growable: false),
        metrics: (json['metrics'] as Map<dynamic, dynamic>? ?? const {}).map(
          (key, value) => MapEntry('$key', '$value'),
        ),
        parties: (json['parties'] as List<dynamic>? ?? const [])
            .map((item) => '$item')
            .toList(growable: false),
      );

  final ReportType type;
  final String summary;
  final String subtitle;
  final List<ReportRow> rows;
  final Map<String, String> metrics;
  final List<String> parties;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'summary': summary,
        'subtitle': subtitle,
        'rows': rows.map((row) => row.toJson()).toList(),
        'metrics': metrics,
        'parties': parties,
      };

  @override
  List<Object?> get props => [type, summary, subtitle, rows, metrics, parties];
}

abstract final class ReportAccess {
  static List<ReportType> forRole(UserRole role) => switch (role) {
        UserRole.financeManager => ReportType.values,
        UserRole.warehouseManager => const [
            ReportType.labourAttendance,
            ReportType.pendingDispatch,
          ],
        UserRole.procurementManager => const [
            ReportType.purchaseRegister,
            ReportType.supplierStatement,
            ReportType.outstanding,
          ],
        UserRole.salesManager => const [
            ReportType.salesRegister,
            ReportType.customerStatement,
            ReportType.pendingDispatch,
            ReportType.outstanding,
          ],
      };
}
