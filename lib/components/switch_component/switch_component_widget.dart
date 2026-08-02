import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SwitchComponentWidget extends StatefulWidget {
  const SwitchComponentWidget({
    super.key,
    this.label = 'Remember Me',
    this.labelPresent = true,
    this.variant = 'Android',
    this.active = true,
  });

  final String label;
  final bool labelPresent;
  final String variant;
  final bool active;

  @override
  State<SwitchComponentWidget> createState() => _SwitchComponentWidgetState();
}

class _SwitchComponentWidgetState extends State<SwitchComponentWidget> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.active;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.variant != 'iOS 26+')
            Switch(
              value: _switchValue,
              onChanged: (newValue) {
                setState(() => _switchValue = newValue);
              },
              activeTrackColor: context.colorScheme.primary,
              inactiveTrackColor: context.colorScheme.outline,
              inactiveThumbColor: context.textTheme.bodySmall!.color,
            ),
          if (widget.variant == 'iOS 26+')
            Container(
              width: 64.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: _switchValue
                    ? context.colorScheme.primary
                    : context.colorScheme.outline,
                borderRadius: BorderRadius.circular(9999.0),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Align(
                  alignment: _switchValue ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: _switchValue
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(9999.0),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.labelPresent)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: Text(
                widget.label,
                style: context.textTheme.bodyMedium!.override(
                  font: GoogleFonts.inter(
                    fontWeight: context.textTheme.bodyMedium!.fontWeight,
                    fontStyle: context.textTheme.bodyMedium!.fontStyle,
                  ),
                  color: context.colorScheme.onSurface,
                  letterSpacing: 0.0,
                  fontWeight: context.textTheme.bodyMedium!.fontWeight,
                  fontStyle: context.textTheme.bodyMedium!.fontStyle,
                  lineHeight: 1.43,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
