import '/components/settings_item/settings_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'settings_group_child_model.dart';
export 'settings_group_child_model.dart';

class SettingsGroupChildWidget extends StatefulWidget {
  const SettingsGroupChildWidget({super.key});

  @override
  State<SettingsGroupChildWidget> createState() =>
      _SettingsGroupChildWidgetState();
}

class _SettingsGroupChildWidgetState extends State<SettingsGroupChildWidget> {
  late SettingsGroupChildModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsGroupChildModel());

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
              Icons.store_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Business Details',
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
              Icons.receipt_long_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Invoice Settings',
            subtitle: 'Prefix, Logo, Signature, Terms',
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
              Icons.percent_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            label: 'Tax & Pricing Rules',
            subtitle: 'GST rates, HSN codes, Currency',
          ),
        ),
      ],
    );
  }
}
