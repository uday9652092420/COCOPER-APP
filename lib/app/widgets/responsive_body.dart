import 'package:flutter/material.dart';

import '../config/constants.dart';

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    required this.child,
    super.key,
    this.maxWidth = AppConstants.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width >=
                      AppConstants.mobileBreakpoint
                  ? 28
                  : 16,
              vertical: 20,
            ),
            child: child,
          ),
        ),
      );
}
