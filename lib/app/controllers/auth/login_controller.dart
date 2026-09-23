import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../repositories/auth/auth_repository.dart';
import '../../models/session/user_session_model.dart';
import '../../routes/app_routes.dart';
import '../../services/exceptions.dart';
import '../shell/shell_controller.dart';

enum LoginStatus {
  idle,
  loading,
  success,
  invalidCredentials,
  accessDenied,
  networkError,
  error
}

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final error = RxnString();
  final status = LoginStatus.idle.obs;

  AuthRepository get _repository => Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    restoreSession();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    FocusManager.instance.primaryFocus?.unfocus();
    error.value = null;
    status.value = LoginStatus.idle;
    final email = usernameController.text.trim();
    final password = passwordController.text;
    if (!(formKey.currentState?.validate() ?? false)) {
      status.value = LoginStatus.error;
      return;
    }
    if (!_isValidEmail(email)) {
      error.value = 'Enter a valid email address.';
      status.value = LoginStatus.error;
      return;
    }
    if (password.isEmpty) {
      error.value = 'Enter your password.';
      status.value = LoginStatus.error;
      return;
    }

    isLoading.value = true;
    status.value = LoginStatus.loading;
    try {
      final result = await _repository.login(email: email, password: password);
      Get.find<ShellController>().setSession(
        UserSessionModel.fromAuthUser(result.user),
        userPermissions: await _repository.getStoredPermissions(),
        user: result.user,
      );
      status.value = LoginStatus.success;
      await Get.offAllNamed<void>(Routes.home);
    } on AppException catch (exception) {
      status.value = switch (exception.statusCode) {
        401 => LoginStatus.invalidCredentials,
        403 => LoginStatus.accessDenied,
        _ when exception is NetworkException => LoginStatus.networkError,
        _ => LoginStatus.error,
      };
      error.value = exception.message;
    } catch (_) {
      status.value = LoginStatus.error;
      error.value = 'something_went_wrong';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreSession() async {
    if (await Get.find<ShellController>().restoreSession()) {
      await Get.offAllNamed<void>(Routes.home);
    }
  }

  bool _isValidEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
}
