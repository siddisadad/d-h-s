import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'action_item_model.dart';
export 'action_item_model.dart';

class ActionItemWidget extends StatefulWidget {
  const ActionItemWidget({
    super.key,
    String? icon,
    String? label,
    String? target,
    Color? tone,
  })  : this.icon = icon ?? 'add_shopping_cart_rounded',
        this.label = label ?? 'New Sale',
        this.target = target ?? 'SalesInvoiceEntry',
        this.tone = tone ?? const Color(0x00000000);

  final String icon;
  final String label;
  final String target;
  final Color tone;

  @override
  State<ActionItemWidget> createState() => _ActionItemWidgetState();
}

class _ActionItemWidgetState extends State<ActionItemWidget> {
  late ActionItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActionItemModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            color: valueOrDefault<Color>(
              widget.tone,
              FlutterFlowTheme.of(context).primary,
            ),
            shape: BoxShape.rectangle,
          ),
          child: FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 44.0,
            fillColor: Colors.transparent,
            icon: Icon(
              Icons.add_shopping_cart_rounded,
              color: valueOrDefault<Color>(
                widget.tone,
                FlutterFlowTheme.of(context).primary,
              ),
              size: 28.0,
            ),
            onPressed: () {},
          ),
        ),
        Text(
          valueOrDefault<String>(
            widget.label,
            'New Sale',
          ),
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                lineHeight: 1.45,
              ),
        ),
      ].divide(SizedBox(height: 4.0)),
    );
  }
}
