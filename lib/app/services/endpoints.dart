abstract final class EndPoints {
  static const transactionLookups = '/v1/lookups/transactions';
  static const refreshToken = '/v1/auth/refresh-token';

  static String transactions(String route) => '/v1/transactions/$route';
  static String reports(String route) => '/v1/reports/$route';
  static String reportExport(String route) => '/v1/reports/$route/exports';
}
