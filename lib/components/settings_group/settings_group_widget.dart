import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';

class SettingsGroupWidget extends StatelessWidget {
  const SettingsGroupWidget({
    super.key,
    this.title = 'GENERAL PROFILE',
    this.children = const [],
    this.showDividerBetween = true,
  });

  final String title;
  final List<Widget> children;
  final bool showDividerBetween;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
            child: Text(
              title,
              style: context.textTheme.titleSmall!.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: context.colorScheme.outline,
                width: 1.0,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: children.length,
              separatorBuilder: (context, index) => showDividerBetween
                  ? Divider(
                      height: 1,
                      thickness: 1,
                      indent: 56,
                      color: context.colorScheme.outline.withValues(alpha: 0.5),
                    )
                  : const SizedBox.shrink(),
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ].divide(SizedBox(height: context.tokens.space8)),
      ),
    );
  }
}
