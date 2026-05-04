import 'package:flutter/material.dart';

import '../../core/utils/constants.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= AppConstants.tabletBreakpoint) {
          return (desktop ?? tablet ?? mobile)(context);
        } else if (width >= AppConstants.mobileBreakpoint) {
          return (tablet ?? mobile)(context);
        } else {
          return mobile(context);
        }
      },
    );
  }
}

enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= AppConstants.tabletBreakpoint) {
    return DeviceType.desktop;
  } else if (width >= AppConstants.mobileBreakpoint) {
    return DeviceType.tablet;
  } else {
    return DeviceType.mobile;
  }
}

int getMangaGridColumns(BuildContext context) {
  return switch (getDeviceType(context)) {
    DeviceType.mobile => 2,
    DeviceType.tablet => 4,
    DeviceType.desktop => 6,
  };
}
