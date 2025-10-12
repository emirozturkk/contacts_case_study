import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/providers/loading_screen/loading_screen_provider.dart';
import 'package:contacts/screens/home_screen/home_screen.dart';
import 'package:contacts/app_common/snackbar/app_snackbar.dart';

class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  Widget _buildLoadingContent(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(loadingScreenProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: loadingState.when(
          loading: () => _buildLoadingContent(context),
          data: (isComplete) {
            if (isComplete) {
              // Navigate to home screen when loading is complete
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        const AppSnackbarOverlay(child: HomeScreen()),
                  ),
                );
              });
            }
            return _buildLoadingContent(context);
          },
          error: (error, stackTrace) {
            // Even if there's an error, we still want to proceed to the home screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const AppSnackbarOverlay(child: HomeScreen()),
                ),
              );
            });
            return _buildLoadingContent(context);
          },
        ),
      ),
    );
  }
}
