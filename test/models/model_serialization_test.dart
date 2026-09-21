import 'package:cocoper_operations/app/models/reports/report_model.dart';
import 'package:cocoper_operations/app/models/transactions/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transaction record survives JSON round-trip', () {
    final original = TransactionRecord(
      id: 'PI-0448',
      type: TransactionType.purchaseInvoice,
      party: 'Lakshmi Traders',
      date: DateTime.utc(2026, 7, 30),
      status: 'Approved',
      amount: 74500,
      summary: 'Tonnage',
      branchId: 'BR-001',
    );

    expect(TransactionRecord.fromJson(original.toJson()), original);
  });

  test('report data survives JSON round-trip', () {
    const original = ReportData(
      type: ReportType.customerStatement,
      summary: '₹2,84,500',
      subtitle: 'Customer balance',
      parties: ['Green Mart'],
      metrics: {'Balance': '₹2,84,500'},
      rows: [
        ReportRow(
          primary: '24 Jul',
          secondary: 'DS-0821',
          tertiary: 'Sale',
          value: '₹32,400',
        ),
      ],
    );

    expect(ReportData.fromJson(original.toJson()), original);
  });
}
