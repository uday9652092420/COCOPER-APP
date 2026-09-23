import '../../helpers/secure_storage_helper.dart';
import '../../models/auth/auth_models.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      EndPoints.login,
      data: {'email': email, 'password': password, 'client': 'mobile'},
      requireAuthToken: false,
    );
    final result = LoginResponse.fromJson(response.data ?? const {});
    await SecureStorageHelper.storeAccessToken(result.token);
    await SecureStorageHelper.storeAuthUser(result.user.toJson());
    final permissions = await getPermissions(result.user.id);
    await SecureStorageHelper.storePermissions(permissions);
    return result;
  }

  Future<List<String>> getPermissions(String userId) async {
    final response = await ApiService.get<dynamic>(
      EndPoints.userPermissions(userId),
    );
    final data = response.data;
    final raw = data is Map
        ? data['permissions'] ?? data['data'] ?? data['items']
        : data;
    if (raw is! List) return const [];
    return raw
        .map((item) {
          if (item is Map) {
            return item['name'] ??
                item['permission'] ??
                item['permission_name'] ??
                item['permissionName'] ??
                item['feature'] ??
                item['code'];
          }
          return item;
        })
        .whereType<Object>()
        .map((item) => item.toString())
        .toList(growable: false);
  }

  Future<AuthUser?> restoreUser() async {
    final token = await SecureStorageHelper.getAccessToken();
    final user = await SecureStorageHelper.getAuthUser();
    if (token == null || token.isEmpty || user == null) return null;
    return AuthUser.fromStoredJson(user);
  }

  Future<List<String>> getStoredPermissions() =>
      SecureStorageHelper.getPermissions();

  Future<void> logout() async {
    try {
      await ApiService.post<void>(EndPoints.logout);
    } finally {
      await SecureStorageHelper.clearSession();
    }
  }
}
