import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:contacts/app_common/snackbar/app_snackbar_provider.dart';

class AppSnackbarWidget extends ConsumerStatefulWidget {
  const AppSnackbarWidget({super.key});

  @override
  ConsumerState<AppSnackbarWidget> createState() => _AppSnackbarWidgetState();
}

class _AppSnackbarWidgetState extends ConsumerState<AppSnackbarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showSnackbar(SnackbarConfig config) {
    _hideTimer?.cancel();
    _animationController.forward();

    _hideTimer = Timer(config.duration, () {
      _hideSnackbar();
    });
  }

  void _hideSnackbar() {
    _animationController.reverse().then((_) {
      // Check if widget is still mounted before accessing provider
      if (mounted) {
        try {
          ref.read(snackbarProvider.notifier).hideSnackbar();
        } catch (e) {
          // Silently handle error if provider is disposed
          debugPrint(
            "Snackbar provider access error (widget likely disposed): $e",
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snackbarState = ref.watch(snackbarProvider);

    ref.listen<SnackbarState>(snackbarProvider, (previous, current) {
      if (current.isVisible && current.config != null) {
        _showSnackbar(current.config!);
      } else if (!current.isVisible && _animationController.isCompleted) {
        _hideSnackbar();
      }
    });

    if (!snackbarState.isVisible || snackbarState.config == null) {
      return const SizedBox.shrink();
    }

    final config = snackbarState.config!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideValue = _slideAnimation.value;
        final fadeValue = _fadeAnimation.value;

        return Positioned(
          top: config.showBottom
              ? null
              : mediaQuery.padding.top + (50 * (1 - slideValue)),
          bottom: config.showBottom
              ? mediaQuery.padding.bottom + (50 * (1 - slideValue))
              : null,
          left: 16,
          right: 16,
          child: Opacity(
            opacity: fadeValue,
            child: Transform.translate(
              offset: Offset(
                0,
                config.showBottom
                    ? 50 * (1 - slideValue)
                    : -50 * (1 - slideValue),
              ),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color:
                    config.backgroundColor ??
                    theme.snackBarTheme.backgroundColor,
                child: InkWell(
                  onTap: config.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (config.icon != null) ...[
                          Icon(
                            config.icon,
                            color:
                                config.textColor ??
                                theme.snackBarTheme.contentTextStyle?.color,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            config.message,
                            style: TextStyle(
                              color:
                                  config.textColor ??
                                  theme.snackBarTheme.contentTextStyle?.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (config.actionLabel != null &&
                            config.onActionTap != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              config.onActionTap?.call();
                              _hideSnackbar();
                            },
                            child: Text(
                              config.actionLabel!,
                              style: TextStyle(
                                color:
                                    config.textColor ??
                                    theme.snackBarTheme.actionTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        IconButton(
                          onPressed: _hideSnackbar,
                          icon: Icon(
                            Icons.close,
                            color:
                                config.textColor ??
                                theme.snackBarTheme.contentTextStyle?.color,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Overlay wrapper to ensure snackbar appears on top of everything
class AppSnackbarOverlay extends ConsumerWidget {
  final Widget child;

  const AppSnackbarOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(children: [child, const AppSnackbarWidget()]);
  }
}
