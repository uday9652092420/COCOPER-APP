import 'package:cocoper_operations/app/models/session/user_session_model.dart';
import 'package:cocoper_operations/app/models/transactions/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionCalculator', () {
    test('applies ton-wise lessing per 100 kg', () {
      final values = <String, String>{
        FieldKey.quantityMode.name: 'Lessing · Ton wise',
        FieldKey.quantity.name: '1200',
        FieldKey.discount.name: '30',
      };

      expect(TransactionCalculator.actualQuantity(values), 840);
      expect(TransactionCalculator.maxDiscount('Tonnage'), 50);
      expect(TransactionCalculator.notificationThreshold('Tonnage'), 30);
    });

    test('applies piece-wise lessing per 1000 pieces', () {
      final values = <String, String>{
        FieldKey.quantityMode.name: 'Lessing · Piece wise',
        FieldKey.quantity.name: '10000',
        FieldKey.discount.name: '20',
      };

      expect(TransactionCalculator.actualQuantity(values), 9800);
      expect(TransactionCalculator.maxDiscount('Piece wise'), 100);
      expect(TransactionCalculator.notificationThreshold('Piece wise'), 20);
    });

    test('totals labour OT and loading charges', () {
      final values = <String, String>{
        FieldKey.morningOt.name: '2',
        FieldKey.eveningOt.name: '1.5',
        FieldKey.otRate.name: '150',
        FieldKey.loadingCharge.name: '400',
      };

      expect(
        TransactionCalculator.total(TransactionType.labourPayment, values),
        925,
      );
    });
  });

  group('role access', () {
    test('sales manager sees only sales operations', () {
      expect(TransactionAccess.forRole(UserRole.salesManager), const [
        TransactionType.sales,
        TransactionType.customerReceipt,
      ]);
    });

    test('procurement manager can purchase bags', () {
      expect(
        TransactionAccess.forRole(UserRole.procurementManager),
        contains(TransactionType.bagPurchase),
      );
    });
  });
}
