import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../config/constants.dart';

abstract final class SecureStorageHelper {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> storeAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  static Future<void> storeRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.authUserKey),
      _storage.delete(key: AppConstants.authPermissionsKey),
      _storage.delete(key: AppConstants.selectedBranchIdKey),
      _storage.delete(key: AppConstants.organizationIdKey),
    ]);
  }

  static Future<void> storeAuthUser(Map<String, dynamic> user) =>
      _storage.write(key: AppConstants.authUserKey, value: jsonEncode(user));

  static Future<Map<String, dynamic>?> getAuthUser() async {
    final value = await _storage.read(key: AppConstants.authUserKey);
    if (value == null || value.isEmpty) return null;
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  static Future<void> storePermissions(List<String> permissions) =>
      _storage.write(
          key: AppConstants.authPermissionsKey, value: jsonEncode(permissions));

  static Future<List<String>> getPermissions() async {
    final value = await _storage.read(key: AppConstants.authPermissionsKey);
    if (value == null || value.isEmpty) return const [];
    final decoded = jsonDecode(value);
    return decoded is List ? decoded.whereType<String>().toList() : const [];
  }

  static Future<void> storeSelectedBranchId(String branchId) =>
      _storage.write(key: AppConstants.selectedBranchIdKey, value: branchId);

  static Future<String?> getSelectedBranchId() =>
      _storage.read(key: AppConstants.selectedBranchIdKey);

  static Future<void> storeOrganizationId(String organizationId) => _storage
      .write(key: AppConstants.organizationIdKey, value: organizationId);

  static Future<String?> getOrganizationId() =>
      _storage.read(key: AppConstants.organizationIdKey);

  static Future<String?> read(String key) => _storage.read(key: key);
  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
