import '/components/settings_item/settings_item_widget.dart';
import '/components/switch_component/switch_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_group_child3_model.dart';
export 'settings_group_child3_model.dart';

class SettingsGroupChild3Widget extends StatefulWidget {
  const SettingsGroupChild3Widget({super.key});

  @override
  State<SettingsGroupChild3Widget> createState() =>
      _SettingsGroupChild3WidgetState();
}

class _SettingsGroupChild3WidgetState extends State<SettingsGroupChild3Widget> {
  late SettingsGroupChild3Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsGroupChild3Model());

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary10,
                          borderRadius: BorderRadius.circular(12.0),
                          shape: BoxShape.rectangle,
                        ),
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Icon(
                          Icons.dark_mode_rounded,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          size: 22.0,
                        ),
                      ),
                      Text(
                        'Dark Mode',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                              lineHeight: 1.43,
                            ),
                      ),
                    ].divide(SizedBox(width: 16.0)),
                  ),
                  wrapWithModel(
                    model: _model.switchModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SwitchComponentWidget(
                      label: '',
                      labelPresent: false,
                      variant: 'Android',
                      active: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 16.0,
          thickness: 1.0,
          indent: 56.0,
          endIndent: 0.0,
          color: FlutterFlowTheme.of(context).alternate,
        ),
        wrapWithModel(
          model: _model.settingsItemModel,
          updateCallback: () => safeSetState(() {}),
          child: SettingsItemWidget(
            hasSubtitle: true,
            icon: Icon(
              Icons.language_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Language',
            subtitle: 'English (India)',
          ),
        ),
      ],
    );
  }
}
