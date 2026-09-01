import 'package:flutter/material.dart' ;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),

      body: const Center(
        child: Text("Analytics"),
      ),
    );
  }
}