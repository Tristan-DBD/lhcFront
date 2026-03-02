import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return getScreenWidth(context) >= 600 && getScreenWidth(context) < 900;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 900;
  }

  static int getGridCrossAxisCount(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
    final width = getScreenWidth(context);
    if (width < 600) return mobile;
    if (width < 900) return tablet;
    return desktop;
  }

  static double getGridSpacing(BuildContext context, {double mobile = 15, double tablet = 20, double desktop = 25}) {
    final width = getScreenWidth(context);
    if (width < 600) return mobile;
    if (width < 900) return tablet;
    return desktop;
  }

  static double getHorizontalPadding(BuildContext context, {double mobile = 16, double tablet = 24, double desktop = 32}) {
    final width = getScreenWidth(context);
    if (width < 600) return mobile;
    if (width < 900) return tablet;
    return desktop;
  }

  static double getVerticalPadding(BuildContext context, {double mobile = 16, double tablet = 24, double desktop = 32}) {
    final height = getScreenHeight(context);
    if (height < 600) return mobile;
    if (height < 900) return tablet;
    return desktop;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final horizontal = getHorizontalPadding(context);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  static double getCardMaxWidth(BuildContext context, {double maxWidth = 400}) {
    final width = getScreenWidth(context);
    return width > maxWidth ? maxWidth : width;
  }
}
