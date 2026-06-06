import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';
import '../../models/project.dart';

class ToolDockItem {
  final ToolType type;
  final IconData icon;
  final String label;

  const ToolDockItem({
    required this.type,
    required this.icon,
    required this.label,
  });
}

class PopCutToolDock extends StatelessWidget {
  final ToolType? activeTool;
  final ValueChanged<ToolType> onToolTap;
  final List<ToolDockItem> items;

  const PopCutToolDock({
    super.key,
    required this.activeTool,
    required this.onToolTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: PopCutColors.background.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: PopCutColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final isActive = activeTool == item.type;
          return GestureDetector(
            onTap: () => onToolTap(item.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? PopCutColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(
                        color: PopCutColors.primary.withValues(alpha: 0.2),
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: isActive
                        ? PopCutColors.primary
                        : PopCutColors.textSecondary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? PopCutColors.primary
                          : PopCutColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
