import '/components/settings_item/settings_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'settings_group_child2_model.dart';
export 'settings_group_child2_model.dart';

class SettingsGroupChild2Widget extends StatefulWidget {
  const SettingsGroupChild2Widget({super.key});

  @override
  State<SettingsGroupChild2Widget> createState() =>
      _SettingsGroupChild2WidgetState();
}

class _SettingsGroupChild2WidgetState extends State<SettingsGroupChild2Widget> {
  late SettingsGroupChild2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsGroupChild2Model());

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
            hasSubtitle: true,
            icon: Icon(
              Icons.cloud_upload_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Database Backup',
            subtitle: 'Last backup: Today, 02:30 AM',
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
              Icons.sync_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Auto-Sync Settings',
            subtitle: 'Cloud synchronization frequency',
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
          model: _model.settingsItemModel3,
          updateCallback: () => safeSetState(() {}),
          child: SettingsItemWidget(
            hasSubtitle: true,
            icon: Icon(
              Icons.security_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'User Permissions',
            subtitle: 'Manage roles and access control',
          ),
        ),
      ],
    );
  }
}
