import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionItem2Widget extends StatelessWidget {
  const TransactionItem2Widget({
    super.key,
    this.amount = '+₹ 45,200',
    this.category = 'Hardware',
    this.date = 'Today, 02:30 PM',
    this.status = 'Bank Transfer',
    this.title = 'Sales Invoice #8821',
    this.type = 'income',
  });

  final String amount;
  final String category;
  final String date;
  final String status;
  final String title;
  final String type;

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    final accentColor = isIncome ? AppColors.success : context.colorScheme.error;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
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
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  shape: BoxShape.rectangle,
                ),
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Icon(
                  isIncome ? Icons.add_chart_rounded : Icons.payments_rounded,
                  color: accentColor,
                  size: 24.0,
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                    Text(
                      '$category • $date',
                      style: context.textTheme.bodySmall!.override(
                        font: GoogleFonts.inter(
                          fontWeight: context.textTheme.bodySmall!.fontWeight,
                          fontStyle: context.textTheme.bodySmall!.fontStyle,
                        ),
                        color: context.textTheme.bodySmall!.color,
                        letterSpacing: 0.0,
                        fontWeight: context.textTheme.bodySmall!.fontWeight,
                        fontStyle: context.textTheme.bodySmall!.fontStyle,
                        lineHeight: 1.33,
                      ),
                    ),
                  ].divide(SizedBox(width: context.tokens.space4)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: context.textTheme.bodyMedium!.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle: context.textTheme.bodyMedium!.fontStyle,
                      ),
                      color: accentColor,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: context.textTheme.bodyMedium!.fontStyle,
                      lineHeight: 1.43,
                    ),
                  ),
                  Text(
                    status,
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
                ].divide(SizedBox(width: context.tokens.space4)),
              ),
            ].divide(SizedBox(width: context.tokens.space16)),
          ),
        ),
      ),
    );
  }
}
