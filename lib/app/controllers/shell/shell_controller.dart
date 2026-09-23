import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/constants.dart';
import '../../helpers/storage_helper.dart';
import '../../helpers/secure_storage_helper.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../repositories/mobile/mobile_repository.dart';
import '../../models/auth/auth_models.dart';
import '../../models/mobile/mobile_bootstrap_model.dart';
import '../../models/session/user_session_model.dart';
import '../../routes/app_routes.dart';
import '../../services/exceptions.dart';

class ShellController extends GetxController {
  final session = UserSessionModel.demo.obs;
  final isAuthenticated = false.obs;
  final permissions = <String>[].obs;
  final branches = <MobileBranch>[].obs;
  final currentUser = Rxn<AuthUser>();
  final mobileUser = Rxn<MobileUser>();
  final bootstrapLoading = false.obs;
  final bootstrapError = RxnString();
  bool _bootstrapInFlight = false;

  void setSession(UserSessionModel value,
      {List<String> userPermissions = const [], AuthUser? user}) {
    session.value = value;
    permissions.assignAll(userPermissions);
    currentUser.value = user;
    isAuthenticated.value = true;
    loadBootstrap();
  }

  Future<bool> restoreSession() async {
    final user = await Get.find<AuthRepository>().restoreUser();
    if (user == null) return false;
    setSession(
      UserSessionModel.fromAuthUser(user),
      userPermissions: await Get.find<AuthRepository>().getStoredPermissions(),
      user: user,
    );
    return true;
  }

  Future<void> signOut() async {
    await Get.find<AuthRepository>().logout();
    session.value = UserSessionModel.demo;
    permissions.clear();
    isAuthenticated.value = false;
    branches.clear();
    currentUser.value = null;
    mobileUser.value = null;
    bootstrapError.value = null;
    await Get.offAllNamed<void>(Routes.login);
  }

  Future<void> loadBootstrap() async {
    if (_bootstrapInFlight) return;
    _bootstrapInFlight = true;
    bootstrapLoading.value = true;
    bootstrapError.value = null;
    try {
      final bootstrap = await Get.find<MobileRepository>().getMobileBootstrap();
      mobileUser.value = bootstrap.user;
      branches.assignAll(
        bootstrap.branches.where(
          (branch) => branch.status.toUpperCase() == 'ACTIVE',
        ),
      );
      await SecureStorageHelper.storeOrganizationId(bootstrap.organization.id);

      final storedBranchId = await SecureStorageHelper.getSelectedBranchId();
      final selected = branches.firstWhereOrNull(
        (branch) => branch.id == storedBranchId,
      );
      final defaultBranch = branches.firstWhereOrNull(
        (branch) => branch.id == bootstrap.defaultBranchId,
      );
      final nextBranch = selected ??
          defaultBranch ??
          (branches.isEmpty ? null : branches.first);
      if (nextBranch == null) {
        await _clearSelectedBranch();
      } else {
        await _setSelectedBranch(nextBranch);
      }
      session.value = session.value.copyWith(
        organizationId: bootstrap.organization.id,
        organizationName: bootstrap.organization.name,
      );
    } catch (exception) {
      if (exception is SessionExpiredException) {
        await _handleExpiredSession();
        return;
      }
      bootstrapError.value = exception.toString();
      final user = currentUser.value;
      if (user != null && mobileUser.value == null) {
        mobileUser.value = MobileUser(
          id: user.id,
          username: user.username,
          fullName: user.fullName,
          email: user.username,
          mobileNo: '',
          role: user.role,
          userType: user.isSuperAdmin ? 'admin' : 'org',
          profilePicture: '',
        );
        if (user.organizationName.isNotEmpty) {
          session.value = session.value.copyWith(
            organizationName: user.organizationName,
            organizationId: user.organizationId,
          );
        }
      }
    } finally {
      _bootstrapInFlight = false;
      bootstrapLoading.value = false;
    }
  }

  Future<void> selectBranch(String branchId) async {
    final branch = branches.firstWhereOrNull((item) => item.id == branchId);
    if (branch == null || branch.status.toUpperCase() != 'ACTIVE') return;
    final previousId = session.value.branchId;
    final previousName = session.value.branchName;
    await _setSelectedBranch(branch);
    try {
      final result =
          await Get.find<MobileRepository>().selectMobileBranch(branchId);
      await _setSelectedBranch(result.branch);
    } catch (exception) {
      session.value = session.value.copyWith(
        branchId: previousId,
        branchName: previousName,
      );
      await SecureStorageHelper.storeSelectedBranchId(previousId);
      bootstrapError.value = exception.toString();
    }
  }

  Future<void> _handleExpiredSession() async {
    await SecureStorageHelper.clearSession();
    session.value = UserSessionModel.demo;
    permissions.clear();
    branches.clear();
    currentUser.value = null;
    mobileUser.value = null;
    isAuthenticated.value = false;
    await Get.offAllNamed<void>(Routes.login);
  }

  Future<void> _setSelectedBranch(MobileBranch branch) async {
    await SecureStorageHelper.storeSelectedBranchId(branch.id);
    session.value = session.value.copyWith(
      branchId: branch.id,
      branchName: branch.name,
    );
  }

  Future<void> _clearSelectedBranch() async {
    await SecureStorageHelper.write(AppConstants.selectedBranchIdKey, '');
    session.value = session.value.copyWith(branchId: '', branchName: '');
  }

  Future<void> changeLanguage(String languageCode) async {
    await StorageHelper.setLanguage(languageCode);
    await Get.updateLocale(Locale(languageCode));
  }
}
