import '/components/settings_item/settings_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'settings_group_child4_model.dart';
export 'settings_group_child4_model.dart';

class SettingsGroupChild4Widget extends StatefulWidget {
  const SettingsGroupChild4Widget({super.key});

  @override
  State<SettingsGroupChild4Widget> createState() =>
      _SettingsGroupChild4WidgetState();
}

class _SettingsGroupChild4WidgetState extends State<SettingsGroupChild4Widget> {
  late SettingsGroupChild4Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsGroupChild4Model());

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
        wrapWithModel(
          model: _model.settingsItemModel1,
          updateCallback: () => safeSetState(() {}),
          child: SettingsItemWidget(
            hasSubtitle: false,
            icon: Icon(
              Icons.help_outline_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Help & Support',
            subtitle: 'Name, Address, Contact info',
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
          model: _model.settingsItemModel2,
          updateCallback: () => safeSetState(() {}),
          child: SettingsItemWidget(
            hasSubtitle: true,
            icon: Icon(
              Icons.info_outline_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'About Software',
            subtitle: 'Version 2.4.1-stable',
          ),
        ),
      ],
    );
  }
}
