import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../models/session/user_session_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../shell/cocoper_shell.dart';

class ProfileView extends GetView<ShellController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 3,
        body: SingleChildScrollView(
          child: ResponsiveBody(
            child: Obx(
              () {
                final session = controller.session.value;
                final user = controller.currentUser.value;
                final mobileUser = controller.mobileUser.value;
                if (controller.bootstrapLoading.value && mobileUser == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final fullName = mobileUser?.fullName.isNotEmpty == true
                    ? mobileUser!.fullName
                    : session.userName;
                final email = mobileUser?.email ?? '';
                final profilePicture = mobileUser?.profilePicture ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: 'Profile',
                      subtitle: 'Your account and workspace details.',
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: CocoperColors.mint,
                              backgroundImage: profilePicture.isEmpty
                                  ? null
                                  : NetworkImage(profilePicture),
                              child: profilePicture.isEmpty
                                  ? const Icon(Icons.person_rounded,
                                      size: 36, color: CocoperColors.teal)
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(fullName,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(email.isEmpty ? '@${session.username}' : email,
                                style: const TextStyle(
                                    color: CocoperColors.muted)),
                            const SizedBox(height: 4),
                            Text(session.organizationName,
                                style: const TextStyle(
                                    color: CocoperColors.muted,
                                    fontWeight: FontWeight.w700)),
                            const Divider(height: 30),
                            _ProfileRow(
                              icon: Icons.badge_outlined,
                              label: 'Role',
                              value: mobileUser?.role ??
                                  user?.role ??
                                  session.role.translationKey.tr,
                            ),
                            _ProfileRow(
                              icon: Icons.business_outlined,
                              label: 'Organization',
                              value: session.organizationName,
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: controller.signOut,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Sign out'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 20, color: CocoperColors.teal),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: CocoperColors.muted)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
}
