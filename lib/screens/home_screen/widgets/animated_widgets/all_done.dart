import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class AllDone extends StatefulWidget {
  final String message;
  const AllDone({super.key, required this.message});

  @override
  State<AllDone> createState() => _AllDoneState();
}

class _AllDoneState extends State<AllDone> {
  @override
  void initState() {
    super.initState();
    // Auto-pop after 2 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Done.json',
              repeat: false, // Play once
              animate: true, // Auto-play
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
