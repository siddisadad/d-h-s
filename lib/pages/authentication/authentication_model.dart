import '/components/auth_tab/auth_tab_widget.dart';
import '/components/brand_header/brand_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/switch_component/switch_component_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'authentication_widget.dart' show AuthenticationWidget;
import 'package:flutter/material.dart';

class AuthenticationModel extends FlutterFlowModel<AuthenticationWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for BrandHeader.
  late BrandHeaderModel brandHeaderModel;
  // Model for AuthTab.
  late AuthTabModel authTabModel1;
  // Model for AuthTab.
  late AuthTabModel authTabModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for Switch.
  late SwitchComponentModel switchModel;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    brandHeaderModel = createModel(context, () => BrandHeaderModel());
    authTabModel1 = createModel(context, () => AuthTabModel());
    authTabModel2 = createModel(context, () => AuthTabModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    switchModel = createModel(context, () => SwitchComponentModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    brandHeaderModel.dispose();
    authTabModel1.dispose();
    authTabModel2.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    switchModel.dispose();
    buttonModel.dispose();
  }
}
