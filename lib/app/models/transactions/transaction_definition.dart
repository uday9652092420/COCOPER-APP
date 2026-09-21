import 'package:get/get.dart';

import 'transaction_model.dart';

TransactionDefinition transactionDefinition(TransactionType type) {
  final review = TransactionStep(
    title: 'review_title'.tr,
    help: 'review_help'.tr,
    isReview: true,
  );

  TransactionField field(
    FieldKey key,
    FieldKind kind, {
    bool required = true,
    List<String> options = const [],
    String? lookupKey,
  }) =>
      TransactionField(
        key: key,
        label: 'field_${key.name}'.tr,
        kind: kind,
        required: required,
        options: options,
        lookupKey: lookupKey,
      );

  TransactionStep step(
    String titleKey,
    String helpKey,
    List<TransactionField> fields,
  ) =>
      TransactionStep(title: titleKey.tr, help: helpKey.tr, fields: fields);

  final branch = field(
    FieldKey.branch,
    FieldKind.choice,
    lookupKey: 'branches',
  );
  final supplier = field(
    FieldKey.supplier,
    FieldKind.choice,
    lookupKey: 'suppliers',
  );
  final customer = field(
    FieldKey.customer,
    FieldKind.choice,
    lookupKey: 'customers',
  );
  final warehouse = field(
    FieldKey.warehouse,
    FieldKind.choice,
    lookupKey: 'warehouses',
  );
  final item = field(FieldKey.item, FieldKind.choice, lookupKey: 'items');

  final steps = switch (type) {
    TransactionType.purchaseOrder => [
        step('party_title', 'party_help', [
          branch,
          supplier,
          warehouse,
          field(FieldKey.orderNumber, FieldKind.text),
        ]),
        step('quantity_title', 'quantity_help', [
          item,
          field(FieldKey.quantity, FieldKind.decimal),
          field(FieldKey.purchaseRate, FieldKind.money),
        ]),
        review,
      ],
    TransactionType.purchaseInvoice => [
        step('mode_title', 'mode_help', [
          field(
            FieldKey.quantityMode,
            FieldKind.choice,
            options: quantityModeOptions,
          ),
          branch,
          supplier,
          warehouse,
          field(FieldKey.invoiceNumber, FieldKind.text),
        ]),
        step('quantity_title', 'discount_help', [
          item,
          field(FieldKey.quantity, FieldKind.decimal),
          field(FieldKey.discount, FieldKind.decimal, required: false),
          field(FieldKey.actualQuantity, FieldKind.readOnly),
          field(FieldKey.purchaseRate, FieldKind.money),
        ]),
        step('charges_title', 'charges_help', [
          field(FieldKey.loadingCharge, FieldKind.money, required: false),
          field(FieldKey.marketCess, FieldKind.money, required: false),
          field(FieldKey.bagStickCharge, FieldKind.money, required: false),
          field(FieldKey.freight, FieldKind.money, required: false),
        ]),
        review,
      ],
    TransactionType.sales => [
        step('mode_title', 'mode_help', [
          field(
            FieldKey.quantityMode,
            FieldKind.choice,
            options: quantityModeOptions,
          ),
          branch,
          customer,
          warehouse,
          field(FieldKey.orderNumber, FieldKind.text),
        ]),
        step('quantity_title', 'discount_help', [
          item,
          field(FieldKey.quantity, FieldKind.decimal),
          field(FieldKey.discount, FieldKind.decimal, required: false),
          field(FieldKey.actualQuantity, FieldKind.readOnly),
          field(FieldKey.salesRate, FieldKind.money),
        ]),
        step('charges_title', 'charges_help', [
          field(FieldKey.loadingCharge, FieldKind.money, required: false),
          field(FieldKey.bagType, FieldKind.choice, lookupKey: 'bags'),
          field(FieldKey.freight, FieldKind.money, required: false),
        ]),
        review,
      ],
    TransactionType.loadingDispatch => [
        step('vehicle_title', 'vehicle_help', [
          branch,
          customer,
          field(FieldKey.vehicleNumber, FieldKind.text),
          field(FieldKey.driverName, FieldKind.text),
          field(FieldKey.driverMobile, FieldKind.phone),
        ]),
        step('load_title', 'load_help', [
          warehouse,
          item,
          field(
            FieldKey.fillingWeight,
            FieldKind.choice,
            options: const ['120 kg', '150 kg', '180 kg', '200 kg'],
          ),
          field(FieldKey.quantity, FieldKind.decimal),
        ]),
        review,
      ],
    TransactionType.customerReceipt => [
        step('party_title', 'receipt_help', [
          branch,
          customer,
          field(
            FieldKey.invoiceAllocation,
            FieldKind.choice,
            options: invoiceAllocationOptions,
          ),
          field(
            FieldKey.invoice,
            FieldKind.choice,
            lookupKey: 'customerInvoices',
            required: false,
          ),
        ]),
        step('payment_title', 'payment_help', [
          field(FieldKey.paymentMode, FieldKind.choice,
              options: paymentOptions),
          field(FieldKey.amount, FieldKind.money),
        ]),
        review,
      ],
    TransactionType.supplierPayment => [
        step('party_title', 'payment_help', [
          branch,
          supplier,
          field(
            FieldKey.invoiceAllocation,
            FieldKind.choice,
            options: invoiceAllocationOptions,
          ),
          field(
            FieldKey.invoice,
            FieldKind.choice,
            lookupKey: 'supplierInvoices',
            required: false,
          ),
        ]),
        step('payment_title', 'payment_help', [
          field(FieldKey.paymentMode, FieldKind.choice,
              options: paymentOptions),
          field(FieldKey.amount, FieldKind.money),
        ]),
        review,
      ],
    TransactionType.cashBankExpense => [
        step('expense_title', 'expense_help', [
          branch,
          field(
            FieldKey.transactionKind,
            FieldKind.choice,
            options: const ['Expense', 'Other income'],
          ),
          field(
            FieldKey.expenseHead,
            FieldKind.choice,
            lookupKey: 'expenseHeads',
          ),
        ]),
        step('payment_title', 'payment_help', [
          field(FieldKey.paymentMode, FieldKind.choice,
              options: paymentOptions),
          field(FieldKey.amount, FieldKind.money),
          field(FieldKey.description, FieldKind.text),
        ]),
        review,
      ],
    TransactionType.labourPayment => [
        step('worker_title', 'worker_help', [
          branch,
          field(
            FieldKey.workerType,
            FieldKind.choice,
            options: const ['Permanent', 'Temporary'],
          ),
          field(FieldKey.labour, FieldKind.choice, lookupKey: 'labour'),
          field(FieldKey.temporaryWorkerName, FieldKind.text, required: false),
        ]),
        step('wages_title', 'wages_help', [
          field(FieldKey.morningOt, FieldKind.decimal, required: false),
          field(FieldKey.eveningOt, FieldKind.decimal, required: false),
          field(FieldKey.loadingCharge, FieldKind.money, required: false),
          field(FieldKey.otRate, FieldKind.money),
        ]),
        review,
      ],
    TransactionType.bagPurchase => [
        step('party_title', 'party_help', [
          branch,
          supplier,
          field(FieldKey.invoiceNumber, FieldKind.text),
        ]),
        step('quantity_title', 'quantity_help', [
          field(FieldKey.bagType, FieldKind.choice, lookupKey: 'bags'),
          field(FieldKey.quantity, FieldKind.decimal),
          field(FieldKey.purchaseRate, FieldKind.money),
        ]),
        review,
      ],
  };

  return TransactionDefinition(type: type, steps: steps);
}

const quantityModeOptions = <String>[
  'Tonnage',
  'Piece wise',
  'Lessing · Ton wise',
  'Lessing · Piece wise',
];
const invoiceAllocationOptions = <String>['Invoice by invoice', 'Cumulative'];
const paymentOptions = <String>['Cash', 'Bank', 'UPI'];
