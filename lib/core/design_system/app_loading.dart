import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const AppLoading({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: context.colorScheme.primary,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: context.textTheme.labelMedium!.copyWith(color: context.textTheme.bodySmall!.color),
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
