import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../models/session/user_session_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../shell/cocoper_shell.dart';

class MoreView extends GetView<ShellController> {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 3,
        body: SingleChildScrollView(
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                    title: 'More', subtitle: 'Workspace and account settings.'),
                const SizedBox(height: 20),
                Obx(
                  () => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: CocoperColors.mint,
                        child: Icon(Icons.person_rounded,
                            color: CocoperColors.teal),
                      ),
                      title: Text(controller.session.value.userName,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle:
                          Text(controller.session.value.role.translationKey.tr),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_rounded),
                        title: Text('language'.tr),
                        trailing: PopupMenuButton<String>(
                          onSelected: controller.changeLanguage,
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'en', child: Text('English')),
                            PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
                            PopupMenuItem(value: 'te', child: Text('తెలుగు')),
                            PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
                            PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
                          ],
                          child: Text(
                              Get.locale?.languageCode.toUpperCase() ?? 'EN'),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout_rounded,
                            color: CocoperColors.coral),
                        title: const Text('Sign out'),
                        onTap: controller.signOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed<void>(Routes.statements),
                  icon: const Icon(Icons.assessment_outlined),
                  label: const Text('Open statements'),
                ),
              ],
            ),
          ),
        ),
      );
}
