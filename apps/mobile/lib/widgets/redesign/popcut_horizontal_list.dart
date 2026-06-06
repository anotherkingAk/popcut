import 'package:flutter/material.dart';

class PopCutHorizontalList extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final Widget Function(BuildContext, int) itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const PopCutHorizontalList({
    super.key,
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    this.spacing = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class PopCutHorizontalListWithLabel extends StatelessWidget {
  final Widget header;
  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final Widget Function(BuildContext, int) itemBuilder;
  final double spacing;

  const PopCutHorizontalListWithLabel({
    super.key,
    required this.header,
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: header,
        ),
        const SizedBox(height: 14),
        PopCutHorizontalList(
          itemCount: itemCount,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          itemBuilder: itemBuilder,
          spacing: spacing,
        ),
      ],
    );
  }
}
