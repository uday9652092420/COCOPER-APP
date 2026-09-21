import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

class CocoperLogo extends StatelessWidget {
  const CocoperLogo({super.key, this.size = 44, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CocoperColors.teal, Color(0xFF0D7565)],
        ),
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26083F3A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .7,
            height: size * .7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .28)),
            ),
          ),
          Text(
            'C',
            style: TextStyle(
              color: CocoperColors.lime,
              fontSize: size * .58,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Positioned(
            right: size * .16,
            bottom: size * .18,
            child: Container(
              width: size * .15,
              height: size * .22,
              decoration: const BoxDecoration(
                color: CocoperColors.coral,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
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
