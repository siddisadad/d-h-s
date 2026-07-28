import '/components/settings_item/settings_item_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'settings_group_child_widget.dart' show SettingsGroupChildWidget;
import 'package:flutter/material.dart';

class SettingsGroupChildModel
    extends FlutterFlowModel<SettingsGroupChildWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SettingsItem.
  late SettingsItemModel settingsItemModel1;
  // Model for SettingsItem.
  late SettingsItemModel settingsItemModel2;
  // Model for SettingsItem.
  late SettingsItemModel settingsItemModel3;

  @override
  void initState(BuildContext context) {
    settingsItemModel1 = createModel(context, () => SettingsItemModel());
    settingsItemModel2 = createModel(context, () => SettingsItemModel());
    settingsItemModel3 = createModel(context, () => SettingsItemModel());
  }

  @override
  void dispose() {
    settingsItemModel1.dispose();
    settingsItemModel2.dispose();
    settingsItemModel3.dispose();
  }
}
