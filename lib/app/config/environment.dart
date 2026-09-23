abstract final class Environment {
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'COCOPER',
  );
  static const isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4004/api',
  );
  static const useMockBackend = bool.fromEnvironment(
    'USE_MOCK_BACKEND',
    defaultValue: true,
  );
}
