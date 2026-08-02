import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentReportItemWidget extends StatelessWidget {
  const RecentReportItemWidget({
    super.key,
    this.date = '2 hours ago',
    this.icon,
    this.name = 'GSTR-1 Monthly Summary',
    this.type = 'PDF',
  });

  final String date;
  final Widget? icon;
  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: context.colorScheme.outline,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(9999.0),
                  shape: BoxShape.rectangle,
                ),
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: icon,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      style: context.textTheme.bodyMedium!.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle: context.textTheme.bodyMedium!.fontStyle,
                        ),
                        color: context.colorScheme.onSurface,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: context.textTheme.bodyMedium!.fontStyle,
                        lineHeight: 1.43,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          date,
                          style: context.textTheme.labelSmall!.override(
                            font: GoogleFonts.inter(
                              fontWeight: context.textTheme.labelSmall!.fontWeight,
                              fontStyle: context.textTheme.labelSmall!.fontStyle,
                            ),
                            color: context.textTheme.bodySmall!.color,
                            letterSpacing: 0.0,
                            fontWeight: context.textTheme.labelSmall!.fontWeight,
                            fontStyle: context.textTheme.labelSmall!.fontStyle,
                            lineHeight: 1.45,
                          ),
                        ),
                        Container(
                          width: 4.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: context.colorScheme.outline,
                            borderRadius: BorderRadius.circular(9999.0),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        Text(
                          type,
                          style: context.textTheme.labelSmall!.override(
                            font: GoogleFonts.inter(
                              fontWeight: context.textTheme.labelSmall!.fontWeight,
                              fontStyle: context.textTheme.labelSmall!.fontStyle,
                            ),
                            color: context.textTheme.bodySmall!.color,
                            letterSpacing: 0.0,
                            fontWeight: context.textTheme.labelSmall!.fontWeight,
                            fontStyle: context.textTheme.labelSmall!.fontStyle,
                            lineHeight: 1.45,
                          ),
                        ),
                      ].divide(SizedBox(width: context.tokens.space8)),
                    ),
                  ].divide(SizedBox(height: context.tokens.space4)),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.download_rounded,
                      color: context.colorScheme.primary,
                      size: 20.0,
                    ),
                    onPressed: () {
                      print('IconButton pressed ...');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: context.textTheme.bodySmall!.color,
                      size: 20.0,
                    ),
                    onPressed: () {
                      print('IconButton pressed ...');
                    },
                  ),
                ].divide(SizedBox(width: context.tokens.space4)),
              ),
            ].divide(SizedBox(width: context.tokens.space16)),
          ),
        ),
      ),
    );
  }
}
