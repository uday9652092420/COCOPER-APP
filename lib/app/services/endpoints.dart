abstract final class EndPoints {
  static const login = '/auth/login';
  static const mobileBootstrap = '/mobile/bootstrap';
  static const mobileBranchSelection = '/mobile/selection/branch';
  static const logout = '/auth/logout';
  static const transactionLookups = '/v1/lookups/transactions';
  static const refreshToken = '/v1/auth/refresh-token';

  static String transactions(String route) => '/v1/transactions/$route';
  static String reports(String route) => '/v1/reports/$route';
  static String reportExport(String route) => '/v1/reports/$route/exports';
  static String userPermissions(String userId) => '/users/$userId/permissions';
}
