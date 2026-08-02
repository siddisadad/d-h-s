import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemRowWidget extends StatelessWidget {
  const ItemRowWidget({
    super.key,
    this.gst = '18',
    this.name = 'TATA TISCON TMT Bars 12mm',
    this.price = '65,400',
    this.qty = '100',
    this.total = '7,84,800',
    this.onDelete,
  });

  final String gst;
  final String name;
  final String price;
  final String qty;
  final String total;
  final VoidCallback? onDelete;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      name,
                      maxLines: 1,
                      style: context.textTheme.titleSmall!.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontStyle: context.textTheme.titleSmall!.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: context.textTheme.titleSmall!.fontStyle,
                        lineHeight: 1.43,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: context.colorScheme.error,
                      size: 20.0,
                    ),
                    onPressed: () async {
                      onDelete?.call();
                    },
                  ),
                ].divide(SizedBox(width: context.tokens.space16)),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty: $qty',
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
                        Text(
                          'Price: ₹$price',
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
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'GST: $gst%',
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
                      Text(
                        '₹$total',
                        style: context.textTheme.bodyMedium!.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle: context.textTheme.bodyMedium!.fontStyle,
                          ),
                          color: context.colorScheme.primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: context.textTheme.bodyMedium!.fontStyle,
                          lineHeight: 1.43,
                        ),
                      ),
                    ],
                  ),
                ].divide(SizedBox(width: context.tokens.space16)),
              ),
            ].divide(SizedBox(height: context.tokens.space8)),
          ),
        ),
      ),
    );
  }
}
