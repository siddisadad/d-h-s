import '/components/settings_item/settings_item_widget.dart';
import '/components/switch_component/switch_component_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'settings_group_child3_widget.dart' show SettingsGroupChild3Widget;
import 'package:flutter/material.dart';

class SettingsGroupChild3Model
    extends FlutterFlowModel<SettingsGroupChild3Widget> {
  ///  State fields for stateful widgets in this component.

  // Model for Switch.
  late SwitchComponentModel switchModel;
  // Model for SettingsItem.
  late SettingsItemModel settingsItemModel;

  @override
  void initState(BuildContext context) {
    switchModel = createModel(context, () => SwitchComponentModel());
    settingsItemModel = createModel(context, () => SettingsItemModel());
  }

  @override
  void dispose() {
    switchModel.dispose();
    settingsItemModel.dispose();
  }
}
