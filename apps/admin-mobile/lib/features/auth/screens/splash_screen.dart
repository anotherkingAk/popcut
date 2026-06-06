import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleIn = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AdminColors.primary, AdminColors.secondary]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: AdminColors.primary.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text('PopCut Admin', style: AppTypography.displaySmall.copyWith(color: AdminColors.textPrimary)),
                const SizedBox(height: 8),
                Text('Control your ecosystem', style: AppTypography.bodyMedium.copyWith(color: AdminColors.textMuted)),
                const SizedBox(height: 40),
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AdminColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
