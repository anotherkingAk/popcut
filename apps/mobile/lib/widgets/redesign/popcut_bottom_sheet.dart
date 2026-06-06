import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class PopCutBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showDragHandle;

  const PopCutBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.85,
    this.showDragHandle = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.85,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => PopCutBottomSheet(
        child: child,
        title: title,
        trailing: trailing,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: PopCutColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PopCutColors.textMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              if (title != null || trailing != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: PopCutTypography.headline,
                          ),
                        ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
              Expanded(
                child: RawScrollbar(
                  thumbVisibility: true,
                  thickness: 3,
                  radius: const Radius.circular(4),
                  thumbColor: PopCutColors.textMuted.withValues(alpha: 0.3),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
