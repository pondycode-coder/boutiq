import 'package:flutter/material.dart';

class DesignTokens {
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const double spacingXxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  static const double elevationLevel0 = 0;
  static const double elevationLevel1 = 1;
  static const double elevationLevel2 = 3;
  static const double elevationLevel3 = 6;
  static const double elevationLevel4 = 12;

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
}

extension ContextExtensions on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < DesignTokens.breakpointMobile;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= DesignTokens.breakpointMobile &&
      MediaQuery.of(this).size.width < DesignTokens.breakpointDesktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= DesignTokens.breakpointDesktop;
}