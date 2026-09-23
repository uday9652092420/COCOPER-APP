import '../../config/constants.dart';
import '../auth/auth_models.dart';

enum UserRole {
  financeManager,
  warehouseManager,
  procurementManager,
  salesManager,
}

extension UserRoleX on UserRole {
  String get apiValue => switch (this) {
        UserRole.financeManager => 'finance_manager',
        UserRole.warehouseManager => 'warehouse_manager',
        UserRole.procurementManager => 'procurement_manager',
        UserRole.salesManager => 'sales_manager',
      };

  String get translationKey => '${apiValue}_role';
}

class UserSessionModel {
  const UserSessionModel({
    required this.userId,
    required this.userName,
    required this.role,
    required this.branchId,
    required this.branchName,
    required this.username,
    required this.organizationId,
    required this.organizationName,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) =>
      UserSessionModel(
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        role: UserRole.values.byName(json['role'] as String),
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String,
        username: json['username'] as String? ?? json['userName'] as String,
        organizationId: json['organizationId'] as String? ?? '',
        organizationName:
            json['organizationName'] as String? ?? json['branchName'] as String,
      );

  static const demo = UserSessionModel(
    userId: 'USR-001',
    userName: 'Raju Kumar',
    role: UserRole.financeManager,
    branchId: AppConstants.branchId,
    branchName: AppConstants.branchName,
    username: 'Uday',
    organizationId: 'ORG-001',
    organizationName: 'COCOPER',
  );

  factory UserSessionModel.fromAuthUser(AuthUser user) => UserSessionModel(
        userId: user.id,
        userName: user.fullName,
        role: _roleFromBackend(user.role, user.isSuperAdmin),
        branchId: user.organizationId.isEmpty ? '' : '',
        branchName: '',
        username: user.username,
        organizationId: user.organizationId,
        organizationName:
            user.organizationName.isEmpty ? 'COCOPER' : user.organizationName,
      );

  static UserRole _roleFromBackend(String value, bool isSuperAdmin) {
    if (isSuperAdmin || value.toUpperCase() == 'ADMIN') {
      return UserRole.financeManager;
    }
    return switch (value.toUpperCase()) {
      'FINANCE_MANAGER' || 'FINANCE' => UserRole.financeManager,
      'WAREHOUSE_MANAGER' || 'WAREHOUSE' => UserRole.warehouseManager,
      'PROCUREMENT_MANAGER' || 'PROCUREMENT' => UserRole.procurementManager,
      'SALES_MANAGER' || 'SALES' => UserRole.salesManager,
      _ => UserRole.warehouseManager,
    };
  }

  final String userId;
  final String userName;
  final UserRole role;
  final String branchId;
  final String branchName;
  final String username;
  final String organizationId;
  final String organizationName;

  UserSessionModel copyWith({
    String? branchId,
    String? branchName,
    String? organizationId,
    String? organizationName,
  }) =>
      UserSessionModel(
        userId: userId,
        userName: userName,
        role: role,
        branchId: branchId ?? this.branchId,
        branchName: branchName ?? this.branchName,
        username: username,
        organizationId: organizationId ?? this.organizationId,
        organizationName: organizationName ?? this.organizationName,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'role': role.name,
        'branchId': branchId,
        'branchName': branchName,
        'username': username,
        'organizationId': organizationId,
        'organizationName': organizationName,
      };
}
