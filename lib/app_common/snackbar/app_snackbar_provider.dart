import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Snackbar configuration model
class SnackbarConfig {
  final String message;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool showBottom;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SnackbarConfig({
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.showBottom = true,
    this.onTap,
    this.actionLabel,
    this.onActionTap,
  });
}

// Snackbar state
class SnackbarState {
  final bool isVisible;
  final SnackbarConfig? config;

  const SnackbarState({this.isVisible = false, this.config});

  SnackbarState copyWith({bool? isVisible, SnackbarConfig? config}) {
    return SnackbarState(
      isVisible: isVisible ?? this.isVisible,
      config: config ?? this.config,
    );
  }
}

// Snackbar notifier
class SnackbarNotifier extends Notifier<SnackbarState> {
  @override
  SnackbarState build() {
    return const SnackbarState();
  }

  void showSnackbar(SnackbarConfig config) {
    state = SnackbarState(isVisible: true, config: config);
  }

  void hideSnackbar() {
    state = const SnackbarState(isVisible: false);
  }

  // Convenience methods
  void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    showSnackbar(
      SnackbarConfig(
        message: message,
        duration: duration,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        icon: Icons.check_circle,
        showBottom: showBottom,
        onTap: onTap,
      ),
    );
  }

  void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    showSnackbar(
      SnackbarConfig(
        message: message,
        duration: duration,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
        showBottom: showBottom,
        onTap: onTap,
      ),
    );
  }

  void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    showSnackbar(
      SnackbarConfig(
        message: message,
        duration: duration,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        icon: Icons.warning,
        showBottom: showBottom,
        onTap: onTap,
      ),
    );
  }

  void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showBottom = true,
    VoidCallback? onTap,
  }) {
    showSnackbar(
      SnackbarConfig(
        message: message,
        duration: duration,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        icon: Icons.info,
        showBottom: showBottom,
        onTap: onTap,
      ),
    );
  }
}

// Provider
final snackbarProvider = NotifierProvider<SnackbarNotifier, SnackbarState>(
  SnackbarNotifier.new,
);
