import 'package:get/get.dart';

import '../bindings/reports/report_catalog_binding.dart';
import '../bindings/reports/report_detail_binding.dart';
import '../bindings/shell/app_binding.dart';
import '../bindings/transactions/transaction_catalog_binding.dart';
import '../bindings/transactions/transaction_detail_binding.dart';
import '../bindings/transactions/transaction_form_binding.dart';
import '../bindings/transactions/transaction_list_binding.dart';
import '../views/reports/report_catalog_view.dart';
import '../views/reports/report_detail_view.dart';
import '../views/transactions/transaction_catalog_view.dart';
import '../views/transactions/transaction_detail_view.dart';
import '../views/transactions/transaction_form_view.dart';
import '../views/transactions/transaction_list_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const initialPage = Routes.transactions;
  static final initialBinding = AppBinding();

  static final routes = <GetPage<dynamic>>[
    GetPage<void>(
      name: Routes.transactions,
      page: TransactionCatalogView.new,
      binding: TransactionCatalogBinding(),
    ),
    GetPage<void>(
      name: Routes.transactionNew,
      page: TransactionFormView.new,
      binding: TransactionFormBinding(),
    ),
    GetPage<void>(
      name: Routes.transactionDetail,
      page: TransactionDetailView.new,
      binding: TransactionDetailBinding(),
    ),
    GetPage<void>(
      name: Routes.transactionList,
      page: TransactionListView.new,
      binding: TransactionListBinding(),
    ),
    GetPage<void>(
      name: Routes.reports,
      page: ReportCatalogView.new,
      binding: ReportCatalogBinding(),
    ),
    GetPage<void>(
      name: Routes.reportDetail,
      page: ReportDetailView.new,
      binding: ReportDetailBinding(),
    ),
  ];
}
