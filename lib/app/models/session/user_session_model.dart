import '../../config/constants.dart';

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
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) =>
      UserSessionModel(
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        role: UserRole.values.byName(json['role'] as String),
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String,
      );

  static const demo = UserSessionModel(
    userId: 'USR-001',
    userName: 'Raju Kumar',
    role: UserRole.financeManager,
    branchId: AppConstants.branchId,
    branchName: AppConstants.branchName,
  );

  final String userId;
  final String userName;
  final UserRole role;
  final String branchId;
  final String branchName;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'role': role.name,
        'branchId': branchId,
        'branchName': branchName,
      };
}
