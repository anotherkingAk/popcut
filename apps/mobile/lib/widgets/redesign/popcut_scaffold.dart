import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';
import 'popcut_bottom_nav.dart';

class PopCutScaffold extends StatelessWidget {
  final Widget body;
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final List<BottomNavItem> navItems;
  final Widget? appBar;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const PopCutScaffold({
    super.key,
    required this.body,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.navItems,
    this.appBar,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? PopCutColors.background,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: appBar,
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: body,
      ),
      bottomNavigationBar: PopCutBottomNav(
        currentIndex: currentNavIndex,
        onTap: onNavTap,
        items: navItems,
      ),
    );
  }
}
