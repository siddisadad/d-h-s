import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(
      duration: 1200.ms,
      color: theme.dividerColor.withValues(alpha: 0.2),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: context.theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 40, height: 40, borderRadius: 20),
          SizedBox(height: tokens.spaceMd),
          const SkeletonLoader(width: 80, height: 12),
          SizedBox(height: tokens.spaceXs),
          const SkeletonLoader(width: 120, height: 24),
        ],
      ),
    );
  }
}
