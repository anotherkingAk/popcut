import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class PopCutCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final bool hasGlow;
  final Color? glowColor;

  const PopCutCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.backgroundColor,
    this.boxShadow,
    this.border,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.gradient,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = boxShadow ?? PopCutShadows.card;

    final allShadows = hasGlow
        ? [
            ...effectiveShadow,
            ...PopCutShadows.glowColor(glowColor ?? PopCutColors.primary,
                intensity: 0.15),
          ]
        : effectiveShadow;

    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient != null ? null : (backgroundColor ?? PopCutColors.surface),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: PopCutColors.border.withValues(alpha: 0.4),
              width: 0.5,
            ),
        boxShadow: allShadows,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}

class PopCutGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool hasGlow;
  final Color? glowColor;
  final double blur;

  const PopCutGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.onTap,
    this.margin,
    this.hasGlow = false,
    this.glowColor,
    this.blur = 20,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PopCutColors.glass(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: PopCutColors.glassBorder(),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: blur,
            offset: const Offset(0, 4),
          ),
          if (hasGlow)
            BoxShadow(
              color: (glowColor ?? PopCutColors.primary).withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
