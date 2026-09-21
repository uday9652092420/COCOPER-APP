import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/reports/report_catalog_controller.dart';
import '../../models/reports/report_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_body.dart';
import '../shell/cocoper_shell.dart';

class ReportCatalogView extends GetView<ReportCatalogController> {
  const ReportCatalogView({super.key});

  @override
  Widget build(BuildContext context) => CocoperShell(
        activeIndex: 1,
        body: SingleChildScrollView(
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                    title: 'reports'.tr, subtitle: 'reports_subtitle'.tr),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1000
                        ? 3
                        : constraints.maxWidth >= 650
                            ? 2
                            : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: columns == 1 ? 2.75 : 1.7,
                      ),
                      itemCount: controller.reports.length,
                      itemBuilder: (_, index) {
                        final type = controller.reports[index];
                        return Card(
                          color: type.tint,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () =>
                                Get.toNamed<void>(Routes.reportFor(type.name)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: CocoperColors.teal,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      type.icon,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          'open_live_report'.tr,
                                          style: const TextStyle(
                                            color: CocoperColors.muted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.north_east_rounded),
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
      );
}
