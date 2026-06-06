import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class PopCutBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const PopCutBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: PopCutColors.background,
        border: Border(
          top: BorderSide(
            color: PopCutColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;
          final isCenter = item.route == 'create';

          if (isCenter) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            PopCutColors.primary,
                            Color(0xFF00B4D8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: PopCutShadows.glow,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: PopCutColors.background,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 22,
                      color: isSelected
                          ? PopCutColors.primary
                          : PopCutColors.textMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? PopCutColors.primary
                            : PopCutColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
