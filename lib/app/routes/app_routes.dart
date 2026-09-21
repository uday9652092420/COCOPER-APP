abstract final class Routes {
  static const transactions = '/transactions';
  static const transactionList = '/transactions/:type';
  static const transactionNew = '/transactions/:type/new';
  static const transactionDetail = '/transactions/:type/:id';
  static const reports = '/reports';
  static const reportDetail = '/reports/:type';

  static String transactionListFor(String type) => '/transactions/$type';
  static String transactionNewFor(String type) => '/transactions/$type/new';
  static String transactionDetailFor(String type, String id) =>
      '/transactions/$type/$id';
  static String reportFor(String type) => '/reports/$type';
}
