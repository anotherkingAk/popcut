import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import 'app_drawer.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: child,
      ),
    );
  }
}
