import 'package:get/get.dart';

import '../controllers/auth/login_controller.dart';
import '../bindings/reports/report_catalog_binding.dart';
import '../bindings/reports/report_detail_binding.dart';
import '../bindings/shell/app_binding.dart';
import '../bindings/transactions/transaction_catalog_binding.dart';
import '../bindings/transactions/transaction_detail_binding.dart';
import '../bindings/transactions/transaction_form_binding.dart';
import '../bindings/transactions/transaction_list_binding.dart';
import '../views/reports/report_catalog_view.dart';
import '../views/reports/report_detail_view.dart';
import '../views/auth/login_view.dart';
import '../views/home/home_view.dart';
import '../views/more/more_view.dart';
import '../views/profile/profile_view.dart';
import '../views/transactions/transaction_catalog_view.dart';
import '../views/transactions/transaction_detail_view.dart';
import '../views/transactions/transaction_form_view.dart';
import '../views/transactions/transaction_list_view.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

abstract final class AppPages {
  static const initialPage = Routes.login;
  static final initialBinding = AppBinding();

  static final routes = <GetPage<dynamic>>[
    GetPage<void>(
      name: Routes.login,
      page: LoginView.new,
      binding: BindingsBuilder<void>(
        () => Get.lazyPut<LoginController>(LoginController.new),
      ),
    ),
    GetPage<void>(
      name: Routes.home,
      page: HomeView.new,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: Routes.transactions,
      page: TransactionCatalogView.new,
      middlewares: [AuthMiddleware()],
      binding: TransactionCatalogBinding(),
    ),
    GetPage<void>(
      name: Routes.transactionNew,
      page: TransactionFormView.new,
      middlewares: [AuthMiddleware()],
      binding: TransactionFormBinding(),
    ),
    GetPage<void>(
      name: Routes.transactionDetail,
      page: TransactionDetailView.new,
      middlewares: [AuthMiddleware()],
      binding: TransactionDetailBinding(),
    ),
    GetPage<void>(
      name: Routes.transactionList,
      page: TransactionListView.new,
      middlewares: [AuthMiddleware()],
      binding: TransactionListBinding(),
    ),
    GetPage<void>(
      name: Routes.reports,
      page: ReportCatalogView.new,
      middlewares: [AuthMiddleware()],
      binding: ReportCatalogBinding(),
    ),
    GetPage<void>(
      name: Routes.statements,
      page: ReportCatalogView.new,
      middlewares: [AuthMiddleware()],
      binding: ReportCatalogBinding(),
    ),
    GetPage<void>(
      name: Routes.more,
      page: MoreView.new,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: Routes.profile,
      page: ProfileView.new,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: Routes.reportDetail,
      page: ReportDetailView.new,
      middlewares: [AuthMiddleware()],
      binding: ReportDetailBinding(),
    ),
  ];
}
