import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/constants.dart';
import '../../controllers/transactions/transaction_catalog_controller.dart';
import '../../models/transactions/transaction_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../shell/cocoper_shell.dart';

class TransactionCatalogView extends GetView<TransactionCatalogController> {
  const TransactionCatalogView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 1,
        body: Obx(
          () => SingleChildScrollView(
            child: ResponsiveBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'transactions'.tr,
                    subtitle:
                        '${'transaction_scope'.tr}: ${controller.roleKey.tr}.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: controller.setQuery,
                    decoration: InputDecoration(
                      hintText: 'search'.tr,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: const Icon(Icons.mic_none_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tablet = constraints.maxWidth >=
                          AppConstants.mobileBreakpoint - 56;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: tablet ? 2 : 1,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: tablet ? 3.45 : 3.05,
                        ),
                        itemCount: controller.transactions.length,
                        itemBuilder: (_, index) {
                          final type = controller.transactions[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => Get.toNamed<void>(
                                  Routes.transactionListFor(type.name)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: type.tint,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        type.icon,
                                        color: CocoperColors.teal,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            type.label,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'transaction_card_hint'.tr,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: CocoperColors.muted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
