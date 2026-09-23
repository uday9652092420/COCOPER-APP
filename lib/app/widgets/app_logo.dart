import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

class CocoperLogo extends StatelessWidget {
  const CocoperLogo({super.key, this.size = 44, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * .22),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
    if (!showWordmark) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'COCOPER',
              style: TextStyle(
                color: CocoperColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            Text(
              'tagline'.tr,
              style: const TextStyle(color: CocoperColors.muted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
