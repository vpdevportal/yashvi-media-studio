import 'package:flutter/material.dart';

/// Extension on BuildContext to provide responsive breakpoint helpers
extension MediaQueryExtensions on BuildContext {
  /// Get the screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get the screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if screen is mobile (< 768px)
  bool get isMobile => screenWidth < 768;

  /// Check if screen is tablet (768px - 1199px)
  bool get isTablet => screenWidth >= 768 && screenWidth < 1200;

  /// Check if screen is small (< 1200px) - shows icon-only sidebar
  bool get isSmallScreen => screenWidth < 1200;

  /// Check if screen is desktop (>= 1200px)
  bool get isDesktop => screenWidth >= 1200;

  /// Check if screen is large desktop (>= 1400px)
  bool get isLargeDesktop => screenWidth >= 1400;

  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(12);
    } else if (isSmallScreen) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else if (isSmallScreen) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// Get responsive vertical padding
  EdgeInsets get responsiveVerticalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(vertical: 12);
    } else if (isSmallScreen) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else {
      return const EdgeInsets.symmetric(vertical: 32);
    }
  }

  /// Get responsive font size multiplier
  double get responsiveFontMultiplier {
    if (isMobile) {
      return 0.9;
    } else if (isSmallScreen) {
      return 0.95;
    } else {
      return 1.0;
    }
  }
}

