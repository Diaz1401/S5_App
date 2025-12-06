import 'package:flutter/material.dart';

class ColorUtils {
  static Color getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'good':
      case 'excellent':
        return colorScheme.primary;
      case 'warning':
      case 'moderate':
        return colorScheme.tertiary;
      case 'critical':
      case 'poor':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }

  static Color getSeverityColor(BuildContext context, String severity) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (severity.toLowerCase()) {
      case 'critical':
        return colorScheme.error;
      case 'warning':
        return colorScheme.tertiary;
      case 'info':
      default:
        return colorScheme.primary;
    }
  }
}
