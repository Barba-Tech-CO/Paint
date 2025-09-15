import 'package:flutter/material.dart';

import 'responsive_dimensions.dart';
import 'responsive_image_dimensions.dart';
import 'responsive_text_styles.dart';

/// Helper class for responsive UI calculations
class ResponsiveHelper {
  // Private constructor to prevent instantiation
  ResponsiveHelper._();

  /// Responsive dimensions for zones card based on screen width
  static ResponsiveDimensions getZonesCardDimensions(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Breakpoints for different screen sizes
    if (screenWidth < 360) {
      // Small screen (small phone)
      return ResponsiveDimensions(
        cardWidth: screenWidth * 0.9,
        imageSize: 80,
        fontSize: 13,
        padding: 8,
        spacing: 2,
      );
    } else if (screenWidth < 600) {
      // Medium screen (normal phone)
      return ResponsiveDimensions(
        cardWidth: 364,
        imageSize: 100,
        fontSize: 14,
        padding: 12,
        spacing: 4,
      );
    } else {
      // Large screen (tablet/desktop)
      return ResponsiveDimensions(
        cardWidth: 380,
        imageSize: 120,
        fontSize: 16,
        padding: 16,
        spacing: 6,
      );
    }
  }

  /// Get responsive text styles for zones card
  static ResponsiveTextStyles getZonesCardTextStyles(BuildContext context) {
    final dimensions = getZonesCardDimensions(context);

    return ResponsiveTextStyles(
      titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: dimensions.fontSize + 2,
      ),
      bodyStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[700],
        fontSize: dimensions.fontSize,
      ),
    );
  }

  /// Responsive dimensions for project card based on screen width
  static ResponsiveDimensions getProjectCardDimensions(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Breakpoints for different screen sizes
    if (screenWidth < 360) {
      // Small screen (small phone)
      return ResponsiveDimensions(
        cardWidth: screenWidth * 0.9,
        imageSize: 80,
        fontSize: 13,
        padding: 8,
        spacing: 2,
      );
    } else if (screenWidth < 600) {
      // Medium screen (normal phone)
      return ResponsiveDimensions(
        cardWidth: 364,
        imageSize: 100,
        fontSize: 14,
        padding: 12,
        spacing: 4,
      );
    } else {
      // Large screen (tablet/desktop)
      return ResponsiveDimensions(
        cardWidth: 380,
        imageSize: 120,
        fontSize: 16,
        padding: 16,
        spacing: 6,
      );
    }
  }

  /// Get responsive text styles for project card
  static ResponsiveTextStyles getProjectCardTextStyles(BuildContext context) {
    final dimensions = getProjectCardDimensions(context);

    return ResponsiveTextStyles(
      titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: dimensions.fontSize + 2,
      ),
      bodyStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[700],
        fontSize: dimensions.fontSize,
      ),
    );
  }

  /// Calculate responsive image dimensions
  static ResponsiveImageDimensions getImageDimensions({
    required double baseImageSize,
    double? customWidth,
    double? customHeight,
  }) {
    final actualImageWidth = customWidth ?? baseImageSize;
    final actualImageHeight = customHeight ?? (baseImageSize * 0.75);

    return ResponsiveImageDimensions(
      width: actualImageWidth,
      height: actualImageHeight,
    );
  }
}
