import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth/login_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Row(
              children: [
                if (wide) const Expanded(child: _LoginWelcome()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: _LoginForm(controller: controller),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class _LoginWelcome extends StatelessWidget {
  const _LoginWelcome();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: CocoperColors.teal,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CocoperLogo(showWordmark: false, size: 68),
            const SizedBox(height: 36),
            Text(
              'Every account operation.\nOne simple app.',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 42,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Buy, sell, dispatch, collect and track your coconut operations from one clear workspace.',
              style: TextStyle(
                  color: Color(0xFFDFF2E7), fontSize: 16, height: 1.5),
            ),
          ],
        ),
      );
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) => Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: CocoperLogo(size: 68)),
            const SizedBox(height: 34),
            Text('Welcome back',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Sign in to your COCOPER workspace.',
              style: TextStyle(color: CocoperColors.muted),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: controller.usernameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
                    ? null
                    : 'Enter a valid email address.';
              },
              decoration: const InputDecoration(
                labelText: 'COCOPER email',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: CocoperColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide:
                      BorderSide(color: CocoperColors.tealSoft, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => TextFormField(
                controller: controller.passwordController,
                obscureText: controller.obscurePassword.value,
                onFieldSubmitted: (_) => controller.signIn(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password.'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: CocoperColors.line),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide:
                        BorderSide(color: CocoperColors.tealSoft, width: 2),
                  ),
                  suffixIcon: IconButton(
                    tooltip: controller.obscurePassword.value
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () => controller.obscurePassword.toggle(),
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => controller.error.value == null
                  ? const SizedBox(height: 22)
                  : Text(
                      controller.error.value!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      controller.isLoading.value ? null : controller.signIn,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                      controller.isLoading.value ? 'Logging in...' : 'Login'),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: CocoperColors.mint.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CocoperColors.line),
              ),
              child: const Column(
                children: [
                  Text(
                    'Super user access',
                    style: TextStyle(
                      color: CocoperColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Username: Uday  •  Password: Uday123',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CocoperColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
