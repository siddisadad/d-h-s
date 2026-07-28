import '/components/button/button_widget.dart';
import '/components/settings_group/settings_group_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'business_settings_widget.dart' show BusinessSettingsWidget;
import 'package:flutter/material.dart';

class BusinessSettingsModel extends FlutterFlowModel<BusinessSettingsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SettingsGroup.
  late SettingsGroupModel settingsGroupModel1;
  // Model for SettingsGroup.
  late SettingsGroupModel settingsGroupModel2;
  // Model for SettingsGroup.
  late SettingsGroupModel settingsGroupModel3;
  // Model for SettingsGroup.
  late SettingsGroupModel settingsGroupModel4;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    settingsGroupModel1 = createModel(context, () => SettingsGroupModel());
    settingsGroupModel2 = createModel(context, () => SettingsGroupModel());
    settingsGroupModel3 = createModel(context, () => SettingsGroupModel());
    settingsGroupModel4 = createModel(context, () => SettingsGroupModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    settingsGroupModel1.dispose();
    settingsGroupModel2.dispose();
    settingsGroupModel3.dispose();
    settingsGroupModel4.dispose();
    buttonModel.dispose();
  }
}
