// Export all snackbar related classes and providers
export 'package:contacts/app_common/snackbar/app_snackbar_provider.dart';
export 'package:contacts/app_common/snackbar/widget/app_snackbar_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/app_common/snackbar/app_snackbar_provider.dart';

// Helper class for easy snackbar usage
class AppSnackbar {
  // Private constructor to prevent instantiation
  AppSnackbar._();

  // Show a custom snackbar
  static void show(
    WidgetRef ref,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool showBottom = true,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    ref
        .read(snackbarProvider.notifier)
        .showSnackbar(
          SnackbarConfig(
            message: message,
            duration: duration,
            backgroundColor: backgroundColor,
            textColor: textColor,
            icon: icon,
            showBottom: showBottom,
            onTap: onTap,
            actionLabel: actionLabel,
            onActionTap: onActionTap,
          ),
        );
  }

  // Show success snackbar
  static void showSuccess(
    WidgetRef ref,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    ref
        .read(snackbarProvider.notifier)
        .showSuccess(
          message,
          duration: duration,
          showBottom: showBottom,
          onTap: onTap,
        );
  }

  // Show error snackbar
  static void showError(
    WidgetRef ref,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    ref
        .read(snackbarProvider.notifier)
        .showError(
          message,
          duration: duration,
          showBottom: showBottom,
          onTap: onTap,
        );
  }

  // Show warning snackbar
  static void showWarning(
    WidgetRef ref,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    ref
        .read(snackbarProvider.notifier)
        .showWarning(
          message,
          duration: duration,
          showBottom: showBottom,
          onTap: onTap,
        );
  }

  // Show info snackbar
  static void showInfo(
    WidgetRef ref,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    ref
        .read(snackbarProvider.notifier)
        .showInfo(
          message,
          duration: duration,
          showBottom: showBottom,
          onTap: onTap,
        );
  }

  // Hide current snackbar
  static void hide(WidgetRef ref) {
    ref.read(snackbarProvider.notifier).hideSnackbar();
  }
}

// Extension for easy access from ConsumerWidget
extension SnackbarExtension on WidgetRef {
  // Show a custom snackbar
  void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool showBottom = true,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    AppSnackbar.show(
      this,
      message,
      duration: duration,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      showBottom: showBottom,
      onTap: onTap,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
    );
  }

  // Show success snackbar
  void showSuccessSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    AppSnackbar.showSuccess(
      this,
      message,
      duration: duration,
      showBottom: showBottom,
      onTap: onTap,
    );
  }

  // Show error snackbar
  void showErrorSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    AppSnackbar.showError(
      this,
      message,
      duration: duration,
      showBottom: showBottom,
      onTap: onTap,
    );
  }

  // Show warning snackbar
  void showWarningSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    AppSnackbar.showWarning(
      this,
      message,
      duration: duration,
      showBottom: showBottom,
      onTap: onTap,
    );
  }

  // Show info snackbar
  void showInfoSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    AppSnackbar.showInfo(
      this,
      message,
      duration: duration,
      showBottom: showBottom,
      onTap: onTap,
    );
  }

  // Hide current snackbar
  void hideSnackbar() {
    AppSnackbar.hide(this);
  }
}
